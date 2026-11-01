import { describe, it, expect } from '@ohos/hypium';
import { QuestionStatus } from '../main/ets/model/QuestionStatus';
import { Question } from '../main/ets/model/Question';
import { MockPageDetector } from '../main/ets/service/mock/MockPageDetector';
import { MockRecognitionService } from '../main/ets/service/mock/MockRecognitionService';
import { MockGradingService } from '../main/ets/service/mock/MockGradingService';
import { MockTutoringService } from '../main/ets/service/mock/MockTutoringService';
import { MockHomeworkData } from '../main/ets/service/mock/MockData';

function findMistake(graded: Question[]): Question | undefined {
  return graded.find((q: Question): boolean => q.status === QuestionStatus.INCORRECT);
}

export default function mockServiceTest() {
  describe('MockServiceTest', () => {
    it('pageDetector_returnsInsetFrame', 0, async () => {
      const frame = await new MockPageDetector().detect('mock://sample');
      expect(frame.x).assertEqual(0.05);
      expect(frame.y).assertEqual(0.05);
      expect(frame.width).assertEqual(0.90);
      expect(frame.height).assertEqual(0.90);
    });

    it('recognition_returnsSixItemsWithValidRegions', 0, async () => {
      const items = await new MockRecognitionService().recognize('mock://sample');
      expect(items.length).assertEqual(6);
      for (let i = 0; i < items.length; i++) {
        expect(items[i].index).assertEqual(i + 1);
        expect(items[i].stem.length > 0).assertTrue();
        expect(items[i].region.x >= 0 && items[i].region.x <= 1).assertTrue();
        expect(items[i].region.y >= 0 && items[i].region.y <= 1).assertTrue();
        expect(items[i].region.x + items[i].region.width <= 1).assertTrue();
        expect(items[i].region.y + items[i].region.height <= 1).assertTrue();
      }
    });

    it('grading_mapsFourStates', 0, async () => {
      const items = await new MockRecognitionService().recognize('mock://sample');
      const graded = await new MockGradingService().grade(items);
      expect(graded.length).assertEqual(6);
      let correct = 0;
      let incorrect = 0;
      let unreadable = 0;
      for (let i = 0; i < graded.length; i++) {
        if (graded[i].status === QuestionStatus.CORRECT) {
          correct++;
        } else if (graded[i].status === QuestionStatus.INCORRECT) {
          incorrect++;
        } else if (graded[i].status === QuestionStatus.UNREADABLE) {
          unreadable++;
        }
      }
      expect(correct).assertEqual(4);
      expect(incorrect).assertEqual(1);
      expect(unreadable).assertEqual(1);
      const mistake = findMistake(graded);
      expect(mistake !== undefined).assertTrue();
      if (mistake !== undefined) {
        expect(mistake.index).assertEqual(MockHomeworkData.MISTAKE_INDEX);
      }
    });

    it('tutoring_explainsMistake', 0, async () => {
      const items = await new MockRecognitionService().recognize('mock://sample');
      const graded = await new MockGradingService().grade(items);
      const mistake = findMistake(graded);
      expect(mistake !== undefined).assertTrue();
      if (mistake !== undefined) {
        const explanation = await new MockTutoringService().explain(mistake);
        expect(explanation.answer).assertEqual('84');
        expect(explanation.steps.length > 0).assertTrue();
        expect(explanation.knowledgePoint.length > 0).assertTrue();
        expect(explanation.possibleCause.startsWith('可能')).assertTrue();
      }
    });
  });
}
