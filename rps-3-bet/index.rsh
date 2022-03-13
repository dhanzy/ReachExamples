'reach 0.1';


const Player = {
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
  const A = Participant('Alice', {
    // Specify Alice's interact interface here
    ...Player,
    wager: UInt,
  });
  const B = Participant('Bob', {
    // Specify Bob's interact interface here
    ...Player,
    acceptWager: Fun([UInt], Null)
  });
  init();
  
  // The second one to publish always attaches
  
  A.only(() => {
    const wager = declassify(interact.wager);
    const handA = declassify(interact.getHand());
  })
  A.publish(wager, handA).pay(wager);
  commit();
  B.only(() =>  {
    interact.acceptWager(wager);
    const handB = declassify(interact.getHand());
  })
  B.publish(handB).pay(wager)
  // The first one to publish deploys the contract
  //commit();
  const outcome = (handA + (4 - handB)) % 3
  each([A, B], () => {
      interact.seeOutcome(outcome);
  })
  const [forAlice, forBob] = outcome == 2 ? [2, 0] : outcome == 0 ? [0, 2] : [1, 1]
  transfer(forAlice * wager).to(A)
  transfer(forBob * wager).to(B);
  commit();
  exit();
});
