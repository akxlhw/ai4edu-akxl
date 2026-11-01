import { Question } from '../../model/Question';
import { QuestionStatus } from '../../model/QuestionStatus';
import { Explanation } from '../../model/Explanation';
import { RecognizedItem } from '../RecognitionService';
import { MockHomeworkData } from './MockData';

/**
 * Mock 判题（设计第 6 节）：固定四态映射 ——
 * 第 5 题 INCORRECT（56+28 写成 74）、第 6 题 UNREADABLE（字迹潦草）、其余 CORRECT。
 * V0.1 mock 数据不含 UNSUPPORTED，但枚举值保留（设计 1.2）。
 */
export class MockGradingService {
  grade(items: RecognizedItem[]): Promise<Question[]> {
    const graded: Question[] = items.map((item: RecognizedItem): Question => {
      let status: QuestionStatus;
      if (item.index === MockHomeworkData.MISTAKE_INDEX) {
        status = QuestionStatus.INCORRECT;
      } else if (item.index === MockHomeworkData.MISTAKE_INDEX + 1) {
        status = QuestionStatus.UNREADABLE;
      } else {
        status = QuestionStatus.CORRECT;
      }
      // CORRECT 题不生成解析；错题解析由 TutoringService 提供
      return new Question(item.index, item.stem, item.studentAnswer, status,
        item.region, new Explanation('', '', [], '', ''));
    });
    return Promise.resolve(graded);
  }
}
