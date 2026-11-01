import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { RectF } from './RectF';

/**
 * 图片加载工具：URI（应用沙箱 file:// 或相册 file://media/...）→ PixelMap。
 * 相册 URI 依赖 PhotoViewPicker 的临时读授权，统一走 fs.openSync(uri)。
 */
export class ImageLoader {
  static async loadPixelMap(uri: string): Promise<image.PixelMap> {
    const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    try {
      const source: image.ImageSource = image.createImageSource(file.fd);
      const pixelMap: image.PixelMap = await source.createPixelMap();
      return pixelMap;
    } finally {
      fs.closeSync(file);
    }
  }

  /**
   * 按归一化区域裁出新的 JPEG 沙箱文件，返回 file:// URI。
   * region 为相对原图的归一化空间 0..1（设计 §7）。
   */
  static async cropToJpegFile(uri: string, region: RectF,
    outPath: string): Promise<string> {
    const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    let pixelMap: image.PixelMap;
    try {
      const source: image.ImageSource = image.createImageSource(file.fd);
      const info: image.ImageInfo = await source.getImageInfo();
      const desiredRegion: image.Region = {
        x: Math.round(region.x * info.size.width),
        y: Math.round(region.y * info.size.height),
        size: {
          width: Math.round(region.width * info.size.width),
          height: Math.round(region.height * info.size.height)
        }
      };
      pixelMap = await source.createPixelMap({ desiredRegion: desiredRegion });
    } finally {
      fs.closeSync(file);
    }
    const packer: image.ImagePacker = image.createImagePacker();
    const buffer: ArrayBuffer = await packer.packing(pixelMap,
      { format: 'image/jpeg', quality: 90 } as image.PackingOption);
    await packer.release();
    await pixelMap.release();
    const out = fs.openSync(outPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    fs.writeSync(out.fd, buffer);
    fs.closeSync(out);
    return `file://${outPath}`;
  }
}
