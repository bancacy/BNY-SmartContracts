const UEquilibriumsPolicy = artifacts.require('UEquilibriumsPolicy.sol');
const MockUEquilibriums = artifacts.require('MockUEquilibriums.sol');
const MockOracle = artifacts.require('MockOracle.sol');

const encodeCall = require('zos-lib/lib/helpers/encodeCall').default;
const BigNumber = web3.BigNumber;
const _require = require('app-root-path').require;
const BlockchainCaller = _require('/util/blockchain_caller');
const chain = new BlockchainCaller(web3);

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

let uEquilibriumsPolicy, mockUEquilibriums, mockMarketOracle, mockSapOracle;
let r, prevEpoch, prevTime;
let deployer, user;

const MAX_RATE = (new BigNumber('1')).mul(10 ** 6 * 10 ** 18);
const MAX_SUPPLY = (new BigNumber(2).pow(255).minus(1)).div(MAX_RATE);
const BASE_SAP = new BigNumber(100e18);
const INITIAL_SAP = new BigNumber(251.712e18);
const INITIAL_SAP_25P_MORE = INITIAL_SAP.mul(1.25).dividedToIntegerBy(1);
const INITIAL_SAP_25P_LESS = INITIAL_SAP.mul(0.77).dividedToIntegerBy(1);
const INITIAL_RATE = INITIAL_SAP.mul(1e18).dividedToIntegerBy(BASE_SAP);
const INITIAL_RATE_30P_MORE = INITIAL_RATE.mul(1.3).dividedToIntegerBy(1);
const INITIAL_RATE_30P_LESS = INITIAL_RATE.mul(0.7).dividedToIntegerBy(1);
const INITIAL_RATE_5P_MORE = INITIAL_RATE.mul(1.05).dividedToIntegerBy(1);
const INITIAL_RATE_5P_LESS = INITIAL_RATE.mul(0.95).dividedToIntegerBy(1);
const INITIAL_RATE_60P_MORE = INITIAL_RATE.mul(1.6).dividedToIntegerBy(1);
const INITIAL_RATE_2X = INITIAL_RATE.mul(2);

async function setupContracts () {
  await chain.waitForSomeTime(86400);
  const accounts = await chain.getUserAccounts();
  deployer = accounts[0];
  user = accounts[1];
  mockUEquilibriums = await MockUEquilibriums.new();
  mockMarketOracle = await MockOracle.new('MarketOracle');
  mockSapOracle = await MockOracle.new('SapOracle');
  uEquilibriumsPolicy = await UEquilibriumsPolicy.new();
  await uEquilibriumsPolicy.sendTransaction({
    data: encodeCall('initialize', ['address', 'address', 'uint256'], [deployer, mockUEquilibriums.address, BASE_SAP.toString()]),
    from: deployer
  });
  await uEquilibriumsPolicy.setMarketOracle(mockMarketOracle.address);
  await uEquilibriumsPolicy.setSapOracle(mockSapOracle.address);
}

async function setupContractsWithOpenRebaseWindow () {
  await setupContracts();
  await uEquilibriumsPolicy.setRebaseTimingParameters(60, 0, 60);
}

async function mockExternalData (rate, sap, uFragSupply, rateValidity = true, sapValidity = true) {
  await mockMarketOracle.storeData(rate);
  await mockMarketOracle.storeValidity(rateValidity);
  await mockSapOracle.storeData(sap);
  await mockSapOracle.storeValidity(sapValidity);
  await mockUEquilibriums.storeSupply(uFragSupply);
}

contract('UEquilibriumsPolicy', function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should reject any ether sent to it', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.sendTransaction({ from: user, value: 1 }))
    ).to.be.true;
  });
});

contract('UEquilibriumsPolicy:initialize', async function (accounts) {
  describe('initial values set correctly', function () {
    before('setup UEquilibriumsPolicy contract', setupContracts);

    it('deviationThreshold', async function () {
      (await uEquilibriumsPolicy.deviationThreshold.call()).should.be.bignumber.eq(0.05e18);
    });
    it('rebaseLag', async function () {
      (await uEquilibriumsPolicy.rebaseLag.call()).should.be.bignumber.eq(30);
    });
    it('minRebaseTimeIntervalSec', async function () {
      (await uEquilibriumsPolicy.minRebaseTimeIntervalSec.call()).should.be.bignumber.eq(24 * 60 * 60);
    });
    it('epoch', async function () {
      (await uEquilibriumsPolicy.epoch.call()).should.be.bignumber.eq(0);
    });
    it('rebaseWindowOffsetSec', async function () {
      (await uEquilibriumsPolicy.rebaseWindowOffsetSec.call()).should.be.bignumber.eq(72000);
    });
    it('rebaseWindowLengthSec', async function () {
      (await uEquilibriumsPolicy.rebaseWindowLengthSec.call()).should.be.bignumber.eq(900);
    });
    it('should set owner', async function () {
      expect(await uEquilibriumsPolicy.owner.call()).to.eq(deployer);
    });
    it('should set reference to uEquilibriums', async function () {
      expect(await uEquilibriumsPolicy.uEquils.call()).to.eq(mockUEquilibriums.address);
    });
  });
});

contract('UEquilibriumsPolicy:setMarketOracle', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should set marketOracle', async function () {
    await uEquilibriumsPolicy.setMarketOracle(deployer);
    expect(await uEquilibriumsPolicy.marketOracle.call()).to.eq(deployer);
  });
});

contract('UEquilibriums:setMarketOracle:accessControl', function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should be callable by owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setMarketOracle(deployer, { from: deployer }))
    ).to.be.false;
  });

  it('should NOT be callable by non-owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setMarketOracle(deployer, { from: user }))
    ).to.be.true;
  });
});

contract('UEquilibriumsPolicy:setSapOracle', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should set sapOracle', async function () {
    await uEquilibriumsPolicy.setSapOracle(deployer);
    expect(await uEquilibriumsPolicy.sapOracle.call()).to.eq(deployer);
  });
});

contract('UEquilibriums:setSapOracle:accessControl', function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should be callable by owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setSapOracle(deployer, { from: deployer }))
    ).to.be.false;
  });

  it('should NOT be callable by non-owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setSapOracle(deployer, { from: user }))
    ).to.be.true;
  });
});

contract('UEquilibriumsPolicy:setDeviationThreshold', async function (accounts) {
  let prevThreshold, threshold;
  before('setup UEquilibriumsPolicy contract', async function () {
    await setupContracts();
    prevThreshold = await uEquilibriumsPolicy.deviationThreshold.call();
    threshold = prevThreshold.plus(0.01e18);
    await uEquilibriumsPolicy.setDeviationThreshold(threshold);
  });

  it('should set deviationThreshold', async function () {
    (await uEquilibriumsPolicy.deviationThreshold.call()).should.be.bignumber.eq(threshold);
  });
});

contract('UEquilibriums:setDeviationThreshold:accessControl', function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should be callable by owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setDeviationThreshold(0, { from: deployer }))
    ).to.be.false;
  });

  it('should NOT be callable by non-owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setDeviationThreshold(0, { from: user }))
    ).to.be.true;
  });
});

contract('UEquilibriumsPolicy:setRebaseLag', async function (accounts) {
  let prevLag;
  before('setup UEquilibriumsPolicy contract', async function () {
    await setupContracts();
    prevLag = await uEquilibriumsPolicy.rebaseLag.call();
  });

  describe('when rebaseLag is more than 0', async function () {
    it('should setRebaseLag', async function () {
      const lag = prevLag.plus(1);
      await uEquilibriumsPolicy.setRebaseLag(lag);
      (await uEquilibriumsPolicy.rebaseLag.call()).should.be.bignumber.eq(lag);
    });
  });

  describe('when rebaseLag is 0', async function () {
    it('should fail', async function () {
      expect(
        await chain.isEthException(uEquilibriumsPolicy.setRebaseLag(0))
      ).to.be.true;
    });
  });
});

contract('UEquilibriums:setRebaseLag:accessControl', function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should be callable by owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setRebaseLag(1, { from: deployer }))
    ).to.be.false;
  });

  it('should NOT be callable by non-owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setRebaseLag(1, { from: user }))
    ).to.be.true;
  });
});

contract('UEquilibriumsPolicy:setRebaseTimingParameters', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', async function () {
    await setupContracts();
  });

  describe('when interval=0', function () {
    it('should fail', async function () {
      expect(
        await chain.isEthException(uEquilibriumsPolicy.setRebaseTimingParameters(0, 0, 0))
      ).to.be.true;
    });
  });

  describe('when offset > interval', function () {
    it('should fail', async function () {
      expect(
        await chain.isEthException(uEquilibriumsPolicy.setRebaseTimingParameters(300, 3600, 300))
      ).to.be.true;
    });
  });

  describe('when params are valid', function () {
    it('should setRebaseTimingParameters', async function () {
      await uEquilibriumsPolicy.setRebaseTimingParameters(600, 60, 300);
      (await uEquilibriumsPolicy.minRebaseTimeIntervalSec.call()).should.be.bignumber.eq(600);
      (await uEquilibriumsPolicy.rebaseWindowOffsetSec.call()).should.be.bignumber.eq(60);
      (await uEquilibriumsPolicy.rebaseWindowLengthSec.call()).should.be.bignumber.eq(300);
    });
  });
});

contract('UEquilibriums:setRebaseTimingParameters:accessControl', function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContracts);

  it('should be callable by owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setRebaseTimingParameters(600, 60, 300, { from: deployer }))
    ).to.be.false;
  });

  it('should NOT be callable by non-owner', async function () {
    expect(
      await chain.isEthException(uEquilibriumsPolicy.setRebaseTimingParameters(600, 60, 300, { from: user }))
    ).to.be.true;
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when minRebaseTimeIntervalSec has NOT passed since the previous rebase', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE_30P_MORE, INITIAL_SAP, 1010);
      await chain.waitForSomeTime(60);
      await uEquilibriumsPolicy.rebase();
    });

    it('should fail', async function () {
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.true;
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when rate is within deviationThreshold', function () {
    before(async function () {
      await uEquilibriumsPolicy.setRebaseTimingParameters(60, 0, 60);
    });

    it('should return 0', async function () {
      await mockExternalData(INITIAL_RATE.minus(1), INITIAL_SAP, 1000);
      await chain.waitForSomeTime(60);
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(0);
      await chain.waitForSomeTime(60);

      await mockExternalData(INITIAL_RATE.plus(1), INITIAL_SAP, 1000);
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(0);
      await chain.waitForSomeTime(60);

      await mockExternalData(INITIAL_RATE_5P_MORE.minus(2), INITIAL_SAP, 1000);
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(0);
      await chain.waitForSomeTime(60);

      await mockExternalData(INITIAL_RATE_5P_LESS.plus(2), INITIAL_SAP, 1000);
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(0);
      await chain.waitForSomeTime(60);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when rate is more than MAX_RATE', function () {
    it('should return same supply delta as delta for MAX_RATE', async function () {
      // Any exchangeRate >= (MAX_RATE=100x) would result in the same supply increase
      await mockExternalData(MAX_RATE, INITIAL_SAP, 1000);
      await chain.waitForSomeTime(60);
      r = await uEquilibriumsPolicy.rebase();
      const supplyChange = r.logs[0].args.requestedSupplyAdjustment;

      await chain.waitForSomeTime(60);

      await mockExternalData(MAX_RATE.add(1e17), INITIAL_SAP, 1000);
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(supplyChange);

      await chain.waitForSomeTime(60);

      await mockExternalData(MAX_RATE.mul(2), INITIAL_SAP, 1000);
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(supplyChange);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when uEquilibriums grows beyond MAX_SUPPLY', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE_2X, INITIAL_SAP, MAX_SUPPLY.minus(1));
      await chain.waitForSomeTime(60);
    });

    it('should apply SupplyAdjustment {MAX_SUPPLY - totalSupply}', async function () {
      // Supply is MAX_SUPPLY-1, exchangeRate is 2x; resulting in a new supply more than MAX_SUPPLY
      // However, supply is ONLY increased by 1 to MAX_SUPPLY
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(1);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when uEquilibriums supply equals MAX_SUPPLY and rebase attempts to grow', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE_2X, INITIAL_SAP, MAX_SUPPLY);
      await chain.waitForSomeTime(60);
    });

    it('should not grow', async function () {
      r = await uEquilibriumsPolicy.rebase();
      r.logs[0].args.requestedSupplyAdjustment.should.be.bignumber.eq(0);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when the market oracle returns invalid data', function () {
    it('should fail', async function () {
      await mockExternalData(INITIAL_RATE_30P_MORE, INITIAL_SAP, 1000, false);
      await chain.waitForSomeTime(60);
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.true;
    });
  });

  describe('when the market oracle returns valid data', function () {
    it('should NOT fail', async function () {
      await mockExternalData(INITIAL_RATE_30P_MORE, INITIAL_SAP, 1000, true);
      await chain.waitForSomeTime(60);
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.false;
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when the sap oracle returns invalid data', function () {
    it('should fail', async function () {
      await mockExternalData(INITIAL_RATE_30P_MORE, INITIAL_SAP, 1000, true, false);
      await chain.waitForSomeTime(60);
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.true;
    });
  });

  describe('when the sap oracle returns valid data', function () {
    it('should NOT fail', async function () {
      await mockExternalData(INITIAL_RATE_30P_MORE, INITIAL_SAP, 1000, true, true);
      await chain.waitForSomeTime(60);
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.false;
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('positive rate and no change sap', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE_30P_MORE, INITIAL_SAP, 1000);
      await uEquilibriumsPolicy.setRebaseTimingParameters(60, 0, 60);
      await chain.waitForSomeTime(60);
      await uEquilibriumsPolicy.rebase();
      await chain.waitForSomeTime(59);
      prevEpoch = await uEquilibriumsPolicy.epoch.call();
      prevTime = await uEquilibriumsPolicy.lastRebaseTimestampSec.call();
      await mockExternalData(INITIAL_RATE_60P_MORE, INITIAL_SAP, 1010);
      r = await uEquilibriumsPolicy.rebase();
    });

    it('should increment epoch', async function () {
      const epoch = await uEquilibriumsPolicy.epoch.call();
      expect(prevEpoch.plus(1).eq(epoch));
    });

    it('should update lastRebaseTimestamp', async function () {
      const time = await uEquilibriumsPolicy.lastRebaseTimestampSec.call();
      expect(time.minus(prevTime).eq(60)).to.be.true;
    });

    it('should emit Rebase with positive requestedSupplyAdjustment', async function () {
      const log = r.logs[0];
      expect(log.event).to.eq('LogRebase');
      expect(log.args.epoch.eq(prevEpoch.plus(1))).to.be.true;
      log.args.exchangeRate.should.be.bignumber.eq(INITIAL_RATE_60P_MORE);
      log.args.sap.should.be.bignumber.eq(INITIAL_SAP);
      log.args.requestedSupplyAdjustment.should.be.bignumber.eq(20);
    });

    it('should call getData from the market oracle', async function () {
      const fnCalled = mockMarketOracle.FunctionCalled().formatter(r.receipt.logs[2]);
      expect(fnCalled.args.instanceName).to.eq('MarketOracle');
      expect(fnCalled.args.functionName).to.eq('getData');
      expect(fnCalled.args.caller).to.eq(uEquilibriumsPolicy.address);
    });

    it('should call getData from the sap oracle', async function () {
      const fnCalled = mockSapOracle.FunctionCalled().formatter(r.receipt.logs[0]);
      expect(fnCalled.args.instanceName).to.eq('SapOracle');
      expect(fnCalled.args.functionName).to.eq('getData');
      expect(fnCalled.args.caller).to.eq(uEquilibriumsPolicy.address);
    });

    it('should call uFrag Rebase', async function () {
      prevEpoch = await uEquilibriumsPolicy.epoch.call();
      const fnCalled = mockUEquilibriums.FunctionCalled().formatter(r.receipt.logs[4]);
      expect(fnCalled.args.instanceName).to.eq('UEquilibriums');
      expect(fnCalled.args.functionName).to.eq('rebase');
      expect(fnCalled.args.caller).to.eq(uEquilibriumsPolicy.address);
      const fnArgs = mockUEquilibriums.FunctionArguments().formatter(r.receipt.logs[5]);
      const parsedFnArgs = Object.keys(fnArgs.args).reduce((m, k) => {
        return fnArgs.args[k].map(d => d.toNumber()).concat(m);
      }, [ ]);
      expect(parsedFnArgs).to.include.members([prevEpoch.toNumber(), 20]);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('negative rate', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE_30P_LESS, INITIAL_SAP, 1000);
      await chain.waitForSomeTime(60);
      r = await uEquilibriumsPolicy.rebase();
    });

    it('should emit Rebase with negative requestedSupplyAdjustment', async function () {
      const log = r.logs[0];
      expect(log.event).to.eq('LogRebase');
      log.args.requestedSupplyAdjustment.should.be.bignumber.eq(-10);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when sap increases', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE, INITIAL_SAP_25P_MORE, 1000);
      await chain.waitForSomeTime(60);
      await uEquilibriumsPolicy.setDeviationThreshold(0);
      r = await uEquilibriumsPolicy.rebase();
    });

    it('should emit Rebase with negative requestedSupplyAdjustment', async function () {
      const log = r.logs[0];
      expect(log.event).to.eq('LogRebase');
      log.args.requestedSupplyAdjustment.should.be.bignumber.eq(-6);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('when sap decreases', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE, INITIAL_SAP_25P_LESS, 1000);
      await chain.waitForSomeTime(60);
      await uEquilibriumsPolicy.setDeviationThreshold(0);
      r = await uEquilibriumsPolicy.rebase();
    });

    it('should emit Rebase with positive requestedSupplyAdjustment', async function () {
      const log = r.logs[0];
      expect(log.event).to.eq('LogRebase');
      log.args.requestedSupplyAdjustment.should.be.bignumber.eq(9);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  before('setup UEquilibriumsPolicy contract', setupContractsWithOpenRebaseWindow);

  describe('rate=TARGET_RATE', function () {
    before(async function () {
      await mockExternalData(INITIAL_RATE, INITIAL_SAP, 1000);
      await uEquilibriumsPolicy.setDeviationThreshold(0);
      await chain.waitForSomeTime(60);
      r = await uEquilibriumsPolicy.rebase();
    });

    it('should emit Rebase with 0 requestedSupplyAdjustment', async function () {
      const log = r.logs[0];
      expect(log.event).to.eq('LogRebase');
      log.args.requestedSupplyAdjustment.should.be.bignumber.eq(0);
    });
  });
});

contract('UEquilibriumsPolicy:Rebase', async function (accounts) {
  let rbTime, rbWindow, minRebaseTimeIntervalSec, now, prevRebaseTime, nextRebaseWindowOpenTime,
    timeToWait, lastRebaseTimestamp;

  beforeEach('setup UEquilibriumsPolicy contract', async function () {
    await setupContracts();
    await uEquilibriumsPolicy.setRebaseTimingParameters(86400, 72000, 900);
    rbTime = await uEquilibriumsPolicy.rebaseWindowOffsetSec.call();
    rbWindow = await uEquilibriumsPolicy.rebaseWindowLengthSec.call();
    minRebaseTimeIntervalSec = await uEquilibriumsPolicy.minRebaseTimeIntervalSec.call();
    now = new BigNumber(await chain.currentTime());
    prevRebaseTime = now.minus(now.mod(minRebaseTimeIntervalSec)).plus(rbTime);
    nextRebaseWindowOpenTime = prevRebaseTime.plus(minRebaseTimeIntervalSec);
  });

  describe('when its 5s after the rebase window closes', function () {
    it('should fail', async function () {
      timeToWait = nextRebaseWindowOpenTime.minus(now).plus(rbWindow).plus(5);
      await chain.waitForSomeTime(timeToWait.toNumber());
      await mockExternalData(INITIAL_RATE, INITIAL_SAP, 1000);
      expect(await uEquilibriumsPolicy.inRebaseWindow.call()).to.be.false;
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.true;
    });
  });

  describe('when its 5s before the rebase window opens', function () {
    it('should fail', async function () {
      timeToWait = nextRebaseWindowOpenTime.minus(now).minus(5);
      await chain.waitForSomeTime(timeToWait.toNumber());
      await mockExternalData(INITIAL_RATE, INITIAL_SAP, 1000);
      expect(await uEquilibriumsPolicy.inRebaseWindow.call()).to.be.false;
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.true;
    });
  });

  describe('when its 5s after the rebase window opens', function () {
    it('should NOT fail', async function () {
      timeToWait = nextRebaseWindowOpenTime.minus(now).plus(5);
      await chain.waitForSomeTime(timeToWait.toNumber());
      await mockExternalData(INITIAL_RATE, INITIAL_SAP, 1000);
      expect(await uEquilibriumsPolicy.inRebaseWindow.call()).to.be.true;
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.false;
      lastRebaseTimestamp = await uEquilibriumsPolicy.lastRebaseTimestampSec.call();
      expect(lastRebaseTimestamp.eq(nextRebaseWindowOpenTime)).to.be.true;
    });
  });

  describe('when its 5s before the rebase window closes', function () {
    it('should NOT fail', async function () {
      timeToWait = nextRebaseWindowOpenTime.minus(now).plus(rbWindow).minus(5);
      await chain.waitForSomeTime(timeToWait.toNumber());
      await mockExternalData(INITIAL_RATE, INITIAL_SAP, 1000);
      expect(await uEquilibriumsPolicy.inRebaseWindow.call()).to.be.true;
      expect(
        await chain.isEthException(uEquilibriumsPolicy.rebase())
      ).to.be.false;
      lastRebaseTimestamp = await uEquilibriumsPolicy.lastRebaseTimestampSec.call();
      expect(lastRebaseTimestamp.eq(nextRebaseWindowOpenTime)).to.be.true;
    });
  });
});
