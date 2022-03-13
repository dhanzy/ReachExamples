'reach 0.1';

const [isHand, ROCK, PAPER, SCISSORS] = makeEnum(3)
const [isOutcome, B_WINS, DRAW, A_WINS] = makeEnum(3)

const winner = (handA, handB) => ((handA + (4 - handB)) % 3)

assert(winner(ROCK, PAPER) == B_WINS)
assert(winner(PAPER, ROCK) == A_WINS)
assert(winner(ROCK, ROCK) == DRAW)

forall(UInt, handA => 
  forall(UInt, handB => 
    assert(isOutcome(winner(handA, handB)))));

forall(UInt, (hand) => 
  assert(winner(hand, hand) == DRAW))


const Player = {
  ...hasRandom,
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null)
}

export const main = Reach.App(() => {
  const A = Participant('Alice', {
    // Specify Alice's interact interface here
    ...Player,
    wager: UInt,
  });
  const B = Participant('Bob', {
    // Specify Bob's interact interface here
    ...Player,
    acceptWager: Fun([UInt], Null),
  });
  init();
  // The first one to publish deploys the contract
  A.only(()=> {
    const wager = declassify(interact.wager)
    const _handA = interact.getHand();
    const [_commitA, _saltA] = makeCommitment(interact, _handA)
    const commitA = declassify(_commitA)
  })
  A.publish(wager, commitA).pay(wager);
  commit();
  // The second one to publish always attaches
  unknowable(B, A(_handA, _saltA));
  B.only(()=> {
    interact.acceptWager(wager);
    const handB = declassify(interact.getHand());
  })
  B.publish(handB).pay(wager);
  commit();
  // write your program here
  A.only(() => {
    const saltA = declassify(_saltA);
    const handA = declassify(_handA)
  })
  A.publish(saltA, handA)
  checkCommitment(commitA, saltA, handA)
  const outcome = winner(handA, handB);
  const [forA, forB] = outcome == A_WINS ? [2, 0]: outcome == B_WINS ? [0, 2]: [1, 1]
  transfer(forA * wager).to(A)
  transfer(forB * wager).to(B)
  commit();
  each([A, B], () => {
    interact.seeOutcome(outcome)
  })
  exit();
});
