import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("Random contract", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployRandomFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, other] = await ethers.getSigners();

    // Deploy the contracts
    const callback = await ethers.deployContract("Callback");
    const dummyVerifier = await ethers.deployContract("DummyVerifier");
    const random = await ethers.deployContract("Random");

    // Get the address of the callback contract
    const callbackAddress = await callback.getAddress();

    return { owner, other, random, callback, callbackAddress, dummyVerifier };
  }

  // Call this function before testing settle_random
  async function prepareForSettleRandom () {
    const { random, callback, callbackAddress, dummyVerifier } = await loadFixture(deployRandomFixture);

    // Set DummyVerifier as the verifier for settle_random
    await random.setVerifier(dummyVerifier);

    // Map 1234 to callbackAddress
    await random.create_random(
      1234, // seed
      callbackAddress // callback
    );

    return { random, callback };
  }

  describe("Constructor", function() {
    it("owner in the Random contract should be the deployer", async function() {
      const { owner, random } = await loadFixture(deployRandomFixture);
      expect(await random.owner()).to.equal(owner.address);
    });
  });

  describe("SetVerifier", function () {
    it("Should revert if the caller is not the owner", async function () {
      const { random, other, dummyVerifier } = await loadFixture(deployRandomFixture);

      await expect(random.connect(other).setVerifier(dummyVerifier)).to.be.revertedWith("Authority: Require Admin");
    });
  });

  describe("CreateRandom", function () {
    it("Should revert if seed already exists", async function () {
      const { random, callbackAddress } = await loadFixture(deployRandomFixture);

      await random.create_random(
        1234, // seed
        callbackAddress // callback
      );
      await expect (
        random.create_random(
          1234, // seed
          callbackAddress // callback
        )
      ).to.be.revertedWith("Seed already exists");
    });

    it("Should map a seed to an address of a callback contract", async function () {
      const { random, callbackAddress } = await loadFixture(deployRandomFixture);

      await random.create_random(
        1234, // seed
        callbackAddress // callback
      );
      expect(await random.smap(1234)).to.equal(callbackAddress);
    });

    it("Should return the right random number", async function () {
      const { owner, random, callbackAddress } = await loadFixture(deployRandomFixture);

      // The create_random is not a view function, use staticCall to get the return value for testing
      const randomNumber = await random.create_random.staticCall(
        1234, // seed
        callbackAddress // callback
      );
      expect(randomNumber[1]).to.equal(ethers.keccak256(ethers.solidityPacked(["uint256", "address", "uint256"], [1234, owner.address, randomNumber[0]])));
    });
  });

  describe("SettleRandom", function() {
    it("Should revert if smap[seed] is zero", async function() {
      const { random } = await loadFixture(deployRandomFixture);

      // 12 is not mapped to any callback address
      await expect(
        random.settle_random(
          12, // seed
          0x1234, // randomNumber
          [0] // proof
        )
      ).to.be.revertedWith("Seed not found");
    });

    it("Should emit Settle event in callback", async function() {
      const { random, callback } = await loadFixture(prepareForSettleRandom);

      await expect(
        random.settle_random(
          1234, // seed
          0x1234, // randomNumber
          [0] // proof
        )
      ).to.emit(callback, "Settle").withArgs(1234, 0x1234);
      // smap[seed] in callback should not be zero
    });

    it("smap[seed] in callback should be randomNumber", async function() {
      const { random, callback } = await loadFixture(prepareForSettleRandom);

      await random.settle_random(
        1234, // seed
        0x1234, // randomNumber
        [0] // proof
      );

      expect(await callback.smap(1234)).to.be.equal(0x1234);
    });

    it("Seed should not exist if settle_random is called twice with the same seed", async function() {
      const { random } = await loadFixture(prepareForSettleRandom);

      await random.settle_random(
        1234, // seed
        0x1234, // randomNumber
        [0] // proof
      );

      await expect(
        random.settle_random(
          1234, // seed
          0x1234, // randomNumber
          [0] // proof
        )
      ).to.be.revertedWith("Seed not found");
    });

    it("If there are multiple seeds and callbacks, the Settle event should be emitted for all randomNumber", async function() {
      const { random, dummyVerifier } = await loadFixture(deployRandomFixture);

      for (let i = 0; i < 30; i++) {
        const callback = await ethers.deployContract("Callback");
        const callbackAddress = await callback.getAddress();

        await random.create_random(
          1234 + i, // seed
          callbackAddress // callback
        );

        // Set DummyVerifier as the verifier for settle_random
        await random.setVerifier(dummyVerifier);

        // Use 0x1234 + i to relace the true random number which cannot get from staticCall
        // because create_random can't be called twice with the same seed
        // The true random number is not important in this stress test
        await expect(
          random.settle_random(
            1234 + i, // seed
            0x1234 + i, // randomNumber
            [0] // proof
          )
        ).to.emit(callback, "Settle").withArgs(1234 + i, 0x1234 + i);
      }
    });
  })
});
