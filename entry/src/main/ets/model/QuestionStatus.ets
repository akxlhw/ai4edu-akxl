/**
 * 单题判题四态（设计第 5 节，PRD A10）。
 * 业务铁律：识别不清不得判错，暂不支持不得强行生成结论。
 */
export enum QuestionStatus {
  /** 正确 */
  CORRECT = 'CORRECT',
  /** 错误 */
  INCORRECT = 'INCORRECT',
  /** 识别不清，需要重拍或人工修正，不计入错误 */
  UNREADABLE = 'UNREADABLE',
  /** 暂不支持 */
  UNSUPPORTED = 'UNSUPPORTED'
}
