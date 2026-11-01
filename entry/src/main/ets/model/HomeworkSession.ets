import { Question } from './Question';
import { QuestionStatus } from './QuestionStatus';

/**
 * 一次作业检查会话（设计第 5 节，V0.1 仅内存态，退出即清）。
 */
export class HomeworkSession {
  /** 处理图（旋转、裁切后）的 URI */
  processedImageUri: string;
  /** 本页全部题目 */
  questions: Question[];
  /** 已查看过解析的错题题号（完成态判断依据） */
  viewedMistakeIndexes: number[];

  constructor(processedImageUri: string, questions: Question[]) {
    this.processedImageUri = processedImageUri;
    this.questions = questions;
    this.viewedMistakeIndexes = [];
  }

  /** INCORRECT 题目列表（UNREADABLE 不算错，PRD 6.1）。 */
  getMistakes(): Question[] {
    return this.questions.filter((q: Question): boolean => q.status === QuestionStatus.INCORRECT);
  }

  /** 标记某题号的错题已查看（幂等）。 */
  markMistakeViewed(index: number): void {
    if (!this.viewedMistakeIndexes.includes(index)) {
      this.viewedMistakeIndexes.push(index);
    }
  }

  /** 全部错题是否均已查看（完成态横幅依据，UX-U06）。 */
  isAllMistakesViewed(): boolean {
    const mistakes = this.getMistakes();
    if (mistakes.length === 0) {
      return false; // 无错题时无"完成浏览"语义，由页面走无错题分支
    }
    return mistakes.every((q: Question): boolean => this.viewedMistakeIndexes.includes(q.index));
  }
}
