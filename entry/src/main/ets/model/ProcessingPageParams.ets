/**
 * CropPage → ProcessingPage 的导航参数：裁切后处理图 URI。
 * 自此进入检查流程；会话对象在处理完成后由 SessionStore 建立。
 */
export class ProcessingPageParams {
  processedImageUri: string;

  constructor(processedImageUri: string) {
    this.processedImageUri = processedImageUri;
  }
}
