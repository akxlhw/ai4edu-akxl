import { RectF } from '../../utils/RectF';
import { Explanation } from '../../model/Explanation';
import { RecognizedItem } from '../RecognitionService';

/**
 * Mock 固定数据：6 道三年级口算（4 对 / 1 错 / 1 处字迹潦草）。
 *
 * ⚠️ 坐标同源约定（设计第 6 节）：本文件的题干与 REGION 布局必须与
 * scripts/generate_sample_homework.ps1（示例作业图生成脚本）保持一致，
 * 修改任何一侧必须同步另一侧，否则示例图上的标注框将与内容错位。
 *
 * 版式（相对处理图的归一化空间）：竖排 6 行，
 * 行 i 的区域 y = 0.07 + i * 0.148，高 0.115；x = 0.06，宽 0.88。
 */

/** 行布局常量（生成脚本按同一公式画题）。 */
export class MockLayout {
  static readonly REGION_X: number = 0.06;
  static readonly REGION_W: number = 0.88;
  static readonly ROW_Y0: number = 0.07;
  static readonly ROW_STEP: number = 0.148;
  static readonly ROW_H: number = 0.115;

  static regionOfRow(row: number): RectF {
    return new RectF(MockLayout.REGION_X,
      MockLayout.ROW_Y0 + row * MockLayout.ROW_STEP,
      MockLayout.REGION_W, MockLayout.ROW_H);
  }
}

/** 题干与学生答案（第 6 题字迹潦草 → 判题为 UNREADABLE）。 */
export class MockHomeworkData {
  static readonly STEMS: string[] = [
    '23 + 45 =',
    '6 × 7 =',
    '81 − 19 =',
    '8 × 9 =',
    '56 + 28 =',
    '64 ÷ 8 ='
  ];
  static readonly STUDENT_ANSWERS: string[] = ['68', '42', '62', '72', '74', '8?'];

  /** 第 5 题的解析（唯一 INCORRECT，MockGradingService/MockTutoringService 使用）。 */
  static readonly MISTAKE_INDEX: number = 5;
  static readonly MISTAKE_EXPLANATION: Explanation = new Explanation(
    '可能算个位时忘了向十位进位',
    '先算个位：6 + 8 = 14，个位写 4，向十位进 1，再算十位。',
    ['个位：6 + 8 = 14，写 4 进 1', '十位：5 + 2 + 1 = 8', '所以 56 + 28 = 84'],
    '84',
    '两位数进位加法'
  );

  /** 固定 6 题识别结果（对任意输入图返回同一组）。 */
  static buildRecognizedItems(): RecognizedItem[] {
    const items: RecognizedItem[] = [];
    for (let i = 0; i < MockHomeworkData.STEMS.length; i++) {
      items.push(new RecognizedItem(i + 1,
        MockHomeworkData.STEMS[i],
        MockHomeworkData.STUDENT_ANSWERS[i],
        MockLayout.regionOfRow(i)));
    }
    return items;
  }
}
