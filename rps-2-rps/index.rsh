'reach 0.1';

const Player = {
    getHand: Fun([], UInt),
    seeOutcome: Fun([UInt], Null),
}


export const main = Reach.App(() => {
  const A = Participant('Alice', {
    // Specify Alice's interact interface here
    ...Player,
  });
  const B = Participant('Bob', {
    // Specify Bob's interact interface here
    ...Player,
  });
  init();
  A.only(() => {
      const handA = declassify(interact.getHand());
  });
  // The first one to publish deploys the contract
  A.publish(handA);
  commit();
  // The second one to publish always attaches
  B.only(() => {
      const handB = declassify(interact.getHand());
  });
  B.publish(handB);
  const outcome = (handA + (4 - handB)) % 3
  commit();
  // write your program here
  each([A, B], () => {
      interact.seeOutcome(outcome);
  })
  exit();
});
