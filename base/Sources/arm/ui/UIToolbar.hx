package arm.ui;

#if (is_paint || is_sculpt)

import kha.System;
import zui.Zui;
import iron.RenderPath;
import arm.Translator._tr;

class UIToolbar {

	public static var inst: UIToolbar;

	#if (krom_android || krom_ios)
	public static inline var defaultToolbarW = 36 + 4;
	#else
	public static inline var defaultToolbarW = 36;
	#end

	public var toolbarHandle = new Handle();
	public var toolbarw = defaultToolbarW;

	public var toolNames = [
		_tr("Brush"),
		_tr("Eraser"),
		_tr("Fill"),
		_tr("Decal"),
		_tr("Text"),
		_tr("Clone"),
		_tr("Blur"),
		_tr("Smudge"),
		_tr("Particle"),
		_tr("ColorID"),
		_tr("Picker"),
		_tr("Gizmo"),
		_tr("Bake")
	];
	var toolCount = [11, 2, 1, 1];

	public function new() {
		inst = this;
	}

	@:access(zui.Zui)
	public function renderUI(g: kha.graphics2.Graphics) {
		var ui = UIBase.inst.ui;

		if (ui.window(toolbarHandle, 0, UIHeader.inst.headerh, toolbarw, System.windowHeight() - UIHeader.inst.headerh)) {
			ui._y -= 4 * ui.SCALE();

			ui.imageScrollAlign = false;
			var img = Res.get("icons.k");
			var imgw = ui.SCALE() > 1 ? 100 : 50;

			var col = ui.t.WINDOW_BG_COL;
			if (col < 0) col += untyped 4294967296;
			var light = col > 0xff666666 + 4294967296;
			var iconAccent = light ? 0xff666666 : -1;

			var rect = Res.tile50(img, 7, 1);
			ui.image(img, light ? 0xff666666 : ui.t.BUTTON_COL, null, rect.x, rect.y, rect.w, rect.h);
			ui._y -= 4 * ui.SCALE();

			var size = UIToolbar.defaultToolbarW - 4;

			#if is_paint
			if (UIHeader.inst.worktab.position == SpacePaint) {
				var keys = [
					"(" + Config.keymap.tool_brush + ") - " + tr("Hold {action_paint} to paint\nHold {key} and press {action_paint} to paint a straight line (ruler mode)", ["key" => Config.keymap.brush_ruler, "action_paint" => Config.keymap.action_paint]),
					"(" + Config.keymap.tool_eraser + ") - " + tr("Hold {action_paint} to erase\nHold {key} and press {action_paint} to erase a straight line (ruler mode)", ["key" => Config.keymap.brush_ruler, "action_paint" => Config.keymap.action_paint]),
					"(" + Config.keymap.tool_fill + ")",
					"(" + Config.keymap.tool_decal + ") - " + tr("Hold {key} to paint on a decal mask", ["key" => Config.keymap.decal_mask]),
					"(" + Config.keymap.tool_text + ") - " + tr("Hold {key} to use the text as a mask", ["key" => Config.keymap.decal_mask]),
					"(" + Config.keymap.tool_clone + ") - " + tr("Hold {key} to set source", ["key" => Config.keymap.set_clone_source]),
					"(" + Config.keymap.tool_blur + ")",
					"(" + Config.keymap.tool_smudge + ")",
					"(" + Config.keymap.tool_particle + ")",
					"(" + Config.keymap.tool_colorid + ")",
					"(" + Config.keymap.tool_picker + ")"
				];

				for (i in 0...toolCount[SpacePaint]) {
					ui._x += 2;
					if (Context.raw.tool == i) drawHighlight();
					var rect = Res.tile50(img, i, 0);
					var _y = ui._y;
					if (ui.image(img, iconAccent, null, rect.x, rect.y, rect.w, rect.h) == State.Started) Context.selectTool(i);
					if (i == ToolColorId && Context.raw.colorIdPicked) {
						ui.g.drawScaledSubImage(RenderPath.active.renderTargets.get("texpaint_colorid").image, 0, 0, 1, 1, 0, _y + 1.5 * ui.SCALE(), 5 * ui.SCALE(), 34 * ui.SCALE());
					}
					if (ui.isHovered) ui.tooltip(tr(toolNames[i]) + " " + keys[i]);
					ui._x -= 2;
					ui._y += 2;
				}
			}
			else if (UIHeader.inst.worktab.position == SpaceMaterial) {
				ui._x += 2;
				if (Context.raw.tool == ToolPicker) drawHighlight();
				if (ui.image(img, iconAccent, null, imgw * ToolPicker, 0, imgw, imgw) == State.Started) Context.selectTool(ToolPicker);
				if (ui.isHovered) ui.tooltip(tr("Picker") + " (V)");
				ui._x -= 2;
				ui._y += 2;
			}
			else if (UIHeader.inst.worktab.position == SpaceBake) {
				ui._x += 2;
				if (Context.raw.tool == ToolBake) drawHighlight();
				if (ui.image(img, iconAccent, null, imgw * ToolBake, 0, imgw, imgw) == State.Started) Context.selectTool(ToolBake);
				if (ui.isHovered) ui.tooltip(tr("Bake") + " (K)");
				ui._x -= 2;
				ui._y += 2;

				ui._x += 2;
				if (Context.raw.tool == ToolPicker) drawHighlight();
				if (ui.image(img, iconAccent, null, imgw * ToolPicker, 0, imgw, imgw) == State.Started) Context.selectTool(ToolPicker);
				if (ui.isHovered) ui.tooltip(tr("Picker") + " (V)");
				ui._x -= 2;
				ui._y += 2;
			}
			#end

			#if is_forge
			if (UIHeader.inst.worktab.position == SpaceScene) {
				ui._x += 2;
				if (Context.raw.tool == ToolGizmo) drawHighlight();
				if (ui.image(img, iconAccent, null, imgw * 11, imgw, imgw, imgw) == State.Started) Context.selectTool(ToolGizmo);
				if (ui.isHovered) ui.tooltip(tr("Gizmo") + " (G)");
				ui._x -= 2;
				ui._y += 2;
			}
			#end

			ui.imageScrollAlign = true;
		}
	}

	@:access(zui.Zui)
	static function drawHighlight() {
		var ui = UIBase.inst.ui;
		var size = (UIToolbar.defaultToolbarW - 4) * ui.SCALE();
		ui.g.color = ui.t.HIGHLIGHT_COL;
		ui.drawRect(ui.g, true, ui._x + -1,  ui._y + 2, size + 2, size + 2);
	}
}

#end
