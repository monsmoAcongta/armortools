package arm.io;

import arm.sys.Path;
import arm.sys.File;
import arm.ui.UINodes;
import arm.ui.UIBox;
import arm.Project;
#if is_paint
import arm.ui.UIHeader;
#end

class ImportAsset {

	public static function run(path: String, dropX = -1.0, dropY = -1.0, showBox = true, hdrAsEnvmap = true, done: Void->Void = null) {

		if (path.startsWith("cloud")) {
			function doCacheCloud() {
				File.cacheCloud(path, function(abs: String) {
					if (abs == null) return;
					run(abs, dropX, dropY, showBox, hdrAsEnvmap, done);
				});
			}

			#if (krom_android || krom_ios)
			arm.App.notifyOnNextFrame(function() {
				Console.toast(tr("Downloading"));
				arm.App.notifyOnNextFrame(doCacheCloud);
			});
			#else
			doCacheCloud();
			#end

			return;
		}

		if (Path.isMesh(path)) {
			showBox ? Project.importMeshBox(path) : ImportMesh.run(path);
			if (dropX > 0) UIBox.clickToHide = false; // Prevent closing when going back to window after drag and drop
		}
		else if (Path.isTexture(path)) {
			ImportTexture.run(path, hdrAsEnvmap);
			// Place image node
			var x0 = UINodes.inst.wx;
			var x1 = UINodes.inst.wx + UINodes.inst.ww;
			if (UINodes.inst.show && dropX > x0 && dropX < x1) {
				var assetIndex = 0;
				for (i in 0...Project.assets.length) {
					if (Project.assets[i].file == path) {
						assetIndex = i;
						break;
					}
				}
				UINodes.inst.acceptAssetDrag(assetIndex);
				UINodes.inst.getNodes().nodesDrag = false;
				UINodes.inst.hwnd.redraws = 2;
			}

			#if is_paint
			if (Context.raw.tool == ToolColorId && Project.assetNames.length == 1) {
				UIHeader.inst.headerHandle.redraws = 2;
				Context.raw.ddirty = 2;
			}
			#end
		}
		else if (Path.isProject(path)) {
			ImportArm.runProject(path);
		}
		else if (Path.isPlugin(path)) {
			ImportPlugin.run(path);
		}
		else if (Path.isGimpColorPalette(path)) {
			ImportGpl.run(path, false);
		}
		#if is_paint
		else if (Path.isFont(path)) {
			ImportFont.run(path);
		}
		else if (Path.isFolder(path)) {
			ImportFolder.run(path);
		}
		#end
		else {
			if (Context.enableImportPlugin(path)) {
				run(path, dropX, dropY, showBox);
			}
			else {
				Console.error(Strings.error1());
			}
		}

		if (done != null) done();
	}
}
