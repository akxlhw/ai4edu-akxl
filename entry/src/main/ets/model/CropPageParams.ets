/**
 * 图片输入来源（决定 CropPage「重拍 / 重新选择」按钮文案，UX-U09）。
 */
export enum ImageSource {
  CAMERA = 'camera',
  ALBUM = 'album'
}

/**
 * CapturePage → CropPage 的导航参数。
 * V0.1 约定：图片经保存/选择后以 URI 传递，会话数据不在此阶段产生。
 */
export class CropPageParams {
  imageUri: string;
  source: ImageSource;

  constructor(imageUri: string, source: ImageSource) {
    this.imageUri = imageUri;
    this.source = source;
  }
}
