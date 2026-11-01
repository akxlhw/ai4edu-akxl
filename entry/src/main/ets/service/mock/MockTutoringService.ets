import { Question } from '../../model/Question';
import { Explanation } from '../../model/Explanation';
import { MockHomeworkData } from './MockData';

/**
 * Mock 辅导：错题返回固定解析（MockData.MISTAKE_EXPLANATION）。
 */
export class MockTutoringService {
  explain(question: Question): Promise<Explanation> {
    if (question.index === MockHomeworkData.MISTAKE_INDEX) {
      return Promise.resolve(MockHomeworkData.MISTAKE_EXPLANATION);
    }
    return Promise.resolve(new Explanation('', '', [], '', ''));
  }
}
