import { hilog } from '@kit.PerformanceKit';

/**
 * 核心漏斗埋点事件（设计第 9 节，UX-U15）。
 * 基线口径：mock 阶段即产生漏斗数据，接入真实 AI 前后可比。
 */
export enum AnalyticsEvent {
  CAPTURE_START = 'capture_start',
  CAPTURE_COMPLETE = 'capture_complete',
  ALBUM_PICKED = 'album_picked',
  CROP_ADJUSTED = 'crop_adjusted',
  CROP_RESET = 'crop_reset',
  CROP_CONFIRMED = 'crop_confirmed',
  PROCESS_CANCELLED = 'process_cancelled',
  PROCESS_COMPLETE = 'process_complete',
  RESULT_VIEWED = 'result_viewed',
  ANNOTATION_TAPPED = 'annotation_tapped',
  QUESTION_CARD_TAPPED = 'question_card_tapped',
  MISTAKE_DETAIL_VIEWED = 'mistake_detail_viewed',
  EXPLANATION_EXPANDED = 'explanation_expanded',
  UNREADABLE_RETAKE_TAPPED = 'unreadable_retake_tapped',
  SESSION_FINISHED = 'session_finished',
  SESSION_ABANDONED = 'session_abandoned'
}

/**
 * 结构化事件日志（hilog）。隐私红线（团队规范）：
 * 只附会话 ID 与时间戳等元数据，不记录图片内容与识别文本。
 */
export class EventLogger {
  private static readonly DOMAIN = 0x0000;
  private static readonly TAG = 'homework_events';

  static log(event: AnalyticsEvent, params: Record<string, string>): void {
    const now = new Date();
    const payload: Record<string, string> = { ts: now.toISOString() };
    const keys = Object.keys(params);
    for (let i = 0; i < keys.length; i++) {
      payload[keys[i]] = params[keys[i]];
    }
    hilog.info(EventLogger.DOMAIN, EventLogger.TAG, '%{public}s %{public}s',
      event, JSON.stringify(payload));
  }
}
