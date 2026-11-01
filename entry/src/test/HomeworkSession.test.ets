import { describe, it, expect } from '@ohos/hypium';
import { RectF } from '../main/ets/utils/RectF';
import { QuestionStatus } from '../main/ets/model/QuestionStatus';
import { Explanation } from '../main/ets/model/Explanation';
import { Question } from '../main/ets/model/Question';
import { HomeworkSession } from '../main/ets/model/HomeworkSession';

const EMPTY_EXPLANATION = new Explanation('', '', [], '', '');

function makeQuestion(index: number, status: QuestionStatus): Question {
  return new Question(index, `题${index}`, '答', status,
    new RectF(0.1, 0.1, 0.8, 0.1), EMPTY_EXPLANATION);
}

export default function homeworkSessionTest() {
  describe('HomeworkSessionTest', () => {
    it('getMistakes_excludesUnreadable', 0, () => {
      const session = new HomeworkSession('uri', [
        makeQuestion(1, QuestionStatus.CORRECT),
        makeQuestion(2, QuestionStatus.INCORRECT),
        makeQuestion(3, QuestionStatus.UNREADABLE)
      ]);
      const mistakes = session.getMistakes();
      expect(mistakes.length).assertEqual(1);
      expect(mistakes[0].index).assertEqual(2);
    });

    it('isAllMistakesViewed_falseWhenNotViewed', 0, () => {
      const session = new HomeworkSession('uri', [
        makeQuestion(1, QuestionStatus.INCORRECT),
        makeQuestion(2, QuestionStatus.INCORRECT)
      ]);
      expect(session.isAllMistakesViewed()).assertFalse();
      session.markMistakeViewed(1);
      expect(session.isAllMistakesViewed()).assertFalse();
    });

    it('isAllMistakesViewed_trueWhenAllViewed', 0, () => {
      const session = new HomeworkSession('uri', [
        makeQuestion(1, QuestionStatus.CORRECT),
        makeQuestion(2, QuestionStatus.INCORRECT),
        makeQuestion(3, QuestionStatus.UNREADABLE)
      ]);
      session.markMistakeViewed(2);
      expect(session.isAllMistakesViewed()).assertTrue();
    });

    it('markMistakeViewed_isIdempotent', 0, () => {
      const session = new HomeworkSession('uri', [
        makeQuestion(1, QuestionStatus.INCORRECT)
      ]);
      session.markMistakeViewed(1);
      session.markMistakeViewed(1);
      expect(session.viewedMistakeIndexes.length).assertEqual(1);
    });

    it('isAllMistakesViewed_falseWhenNoMistakes', 0, () => {
      const session = new HomeworkSession('uri', [
        makeQuestion(1, QuestionStatus.CORRECT)
      ]);
      expect(session.isAllMistakesViewed()).assertFalse();
    });
  });
}
