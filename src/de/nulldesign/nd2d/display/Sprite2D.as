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

package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.ASpriteSheetBase;
	import de.nulldesign.nd2d.materials.Sprite2DMaskMaterial;
	import de.nulldesign.nd2d.materials.Sprite2DMaterial;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.TextureHelper;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;

	/**
	 * <p>2D sprite class</p>
	 * One draw call is used per sprite.
	 * If you have a lot of sprites with the same texture / spritesheet try to use a Sprite2DCould, it will be a lot faster.
	 */
	public class Sprite2D extends Node2D {

		protected var faceList:Vector.<Face>;
		protected var mask:Sprite2D;

		public var texture:Texture2D;
		public var material:Sprite2DMaterial;

		public var usePixelPerfectHitTest:Boolean = false;


        protected override function set batchRoot (value:ContainerNode2D):void
        {
            super.batchRoot = value;
            if (texture == null && value != null && value.texture != null)
            {
                setTexture(value.texture);
            }
        }

		/**
		 * Constructor of class Sprite2D
		 * @param textureObject Texture2D
		 */
		public function Sprite2D(textureObject:Texture2D = null) {
			faceList = TextureHelper.generateQuadFromDimensions(2, 2);

			if(textureObject) {
				setMaterial(new Sprite2DMaterial());
				setTexture(textureObject);
			}
		}

		/**
		 * The texture object
		 * @param Texture2D
		 */
		public function setTexture(value:Texture2D):void {

			this.texture = value;

			if (texture) {
				unscaledWidth = texture.bitmapWidth;
				unscaledHeight = texture.bitmapHeight;
				hasPremultipliedAlphaTexture = texture.hasPremultipliedAlpha;
				blendMode = texture.hasPremultipliedAlpha ? BlendModePresets.NORMAL_PREMULTIPLIED_ALPHA : BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			}
		}

		/**
		 * By default a Sprite2D has an instance of Sprite2DMaterial. You can pass other materials to the sprite to change it's appearance.
		 * @param Sprite2DMaterial
		 */
		public function setMaterial(value:Sprite2DMaterial):void {

			if(material) {
				material.dispose();
			}

			this.material = value;
		}

		/**
		 * The mask texture can be any size, but it needs a 1px padding around the borders, otherwise the masks edges get repeated
		 * Don't disable mipmapping for the masks texture, it won't work...
		 * @param mask sprite
		 */
		public function setMask(mask:Sprite2D):void {

			this.mask = mask;

			if(mask) {
				setMaterial(new Sprite2DMaskMaterial());
			} else {
				setMaterial(new Sprite2DMaterial());
			}
		}

		override public function get numTris():uint {
			return 2;
		}

		override public function get drawCalls():uint {
			return material ? material.drawCalls : 0;
		}


		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();

			if(material)
				material.handleDeviceLoss();

			if(texture)
				texture.texture = null;
		}

		override protected function draw(context:Context3D, camera:Camera2D):void {

			material.blendMode = blendMode;
			material.modelMatrix = worldModelMatrix;
			material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			material.colorTransform = combinedColorTransform;
			material.texture = texture;
			material.nodeTinted = nodeIsTinted;

			if(mask) {

				if(mask.invalidateMatrix) {
					mask.updateLocalMatrix();
				}

				var maskMat:Sprite2DMaskMaterial = Sprite2DMaskMaterial(material);
				maskMat.maskTexture = mask.texture;
				maskMat.maskModelMatrix = mask.localModelMatrix;
				maskMat.maskAlpha = mask.alpha;
			}

			material.render(context, faceList, 0, faceList.length);
		}

		/**
		 * By default, only a bounding rectangle test is made. If you need pixel perfect hittests, enable the usePixelPerfectHitTest.
		 * This only works if this sprite has a Texture2D object with a bitmapData instance. Otherwise pixels can't be read and a default rectangle test is made
		 * @return if the sprite was hit or not
		 */
		override protected function hitTest():Boolean {

			if(usePixelPerfectHitTest && texture.bitmap) {

				var xCoord:Number = _mouseX + halfWidth;
				var yCoord:Number = _mouseY + halfHeight;

				return super.hitTest() && (texture.bitmap.getPixel32(xCoord, yCoord) >> 24 & 0xFF) > 0;
			}

			return super.hitTest();
		}

		override public function dispose():void
		{
			mask = null;

			if(material) 
			{
				material.dispose();
				material = null;
			}

			if(mask) 
			{
				mask.dispose();
				mask = null;
			}

			super.dispose();
		}
	}
}