/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package tests {

    import de.nulldesign.nd2d.display.MovieClip2D;
    import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureAtlas;
	import de.nulldesign.nd2d.materials.texture.parser.TexturePackerParser;

	public class MaskTest extends Scene2D {

		[Embed(source="/assets/textureatlas_cocos2d_allformats.png")]
		private var textureAtlasBitmap:Class;

		[Embed(source="/assets/textureatlas_cocos2d.plist", mimeType="application/octet-stream")]
		private var textureAtlasXML:Class;

		[Embed(source="/assets/spritechar1.png")]
		private var spriteTexture:Class;

		[Embed(source="/assets/crate.jpg")]
		private var spriteImage:Class;

		[Embed(source="/assets/circle_mask.png")]
		private var maskImage:Class;

		private var sprite:MovieClip2D;
		private var sprite2:MovieClip2D;
		private var mask:Sprite2D;

		public function MaskTest() {

			// set up textures, sheets and atlas
			var texAtlasTex:Texture2D = Texture2D.textureFromBitmapData(new textureAtlasBitmap().bitmapData);

			var atlas:TextureAtlas = new TextureAtlas(texAtlasTex.bitmapWidth, texAtlasTex.bitmapHeight,
					new XML(new textureAtlasXML()), new TexturePackerParser());


			var spriteSheetTex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);
			var sheet:SpriteSheet = new SpriteSheet(spriteSheetTex.bitmapWidth, spriteSheetTex.bitmapHeight, 24, 32);

			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteImage().bitmapData);

			// set up test sprite and mask

			sprite = new MovieClip2D(tex, atlas, 20);
            sprite.addAnimationByName("blah", /^[c|b]\d+/, true);
            sprite.playAnimation("blah");
			//sprite.setSpriteSheet(atlas);
			addChild(sprite);

			sprite2 = new MovieClip2D(tex, sheet, 5);
            sprite2.addAnimation("blah", new <uint>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
            sprite2.playAnimation("blah", 0, true);
			//sprite2.setSpriteSheet(atlas);
			addChild(sprite2);

			mask = new Sprite2D(Texture2D.textureFromBitmapData(new maskImage().bitmapData));

			// apply the mask
			sprite.setMask(mask);
			sprite2.setMask(mask);

			// AS3 test for upper left vertex
			/*
			 var v:Vector3D = new Vector3D(128, -128, 0, 1);
			 var clipSpaceMatrix:Matrix3D = new Matrix3D();
			 clipSpaceMatrix.appendTranslation(100, 0, 0);

			 var maskClipSpaceMatrix:Matrix3D = new Matrix3D();
			 maskClipSpaceMatrix.appendTranslation(100, 0, 0);

			 var maskBitmap:Rectangle = new Rectangle(0, 0, 256, 256);

			 maskClipSpaceMatrix.invert();

			 v = clipSpaceMatrix.transformVector(v);
			 trace("moved to clipspace: " + v);

			 // inverted matrix
			 v = maskClipSpaceMatrix.transformVector(v);
			 trace("moved to local mask space: " + v);

			 v = new Vector3D((v.x + (maskBitmap.width * 0.5)) / maskBitmap.width,
			 (v.y + (maskBitmap.height * 0.5)) / maskBitmap.height, 0.0, 1.0);

			 trace("cal local mask uv: " + v);
			 */
		}

		override protected function step(elapsed:Number):void {
			super.step(elapsed);

			sprite.x = camera.sceneHalfWidth;
			sprite.y = camera.sceneHalfHeight;
			sprite.rotation += 2.0;

			sprite2.x = camera.sceneHalfWidth + 256.0;
			sprite2.y = camera.sceneHalfHeight;
			sprite2.rotation += 2.5;

			mask.x = mouseX;
			mask.y = mouseY;
			//mask.alpha = NumberUtil.sin0_1(getTimer() / 500.0);
			//mask.rotation += 4.0;
		}
	}
}
