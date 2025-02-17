package;

import openfl.Lib;
import Discord.DiscordClient;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import MainVariables._variables;
import flixel.tweens.FlxEase;

using StringTools;

class PAGE1settings extends MusicBeatSubstate
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'page', 'resolution', 'fullscreen', 'fpsCounter', 'fps', 'memory', 'hue', 'brightness', 'gamma', 'filter', 'watermark'
	];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	var selectedSomethin:Bool = false;
	var curSelected:Int = 0;
	var camFollow:FlxObject;

	var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var ExplainText:FlxText = new FlxText(20, 69, FlxG.width / 2, "", 48);

	var fil:Int = 0;

	var camLerp:Float = 0.32;

	var navi:FlxSprite;

	public function new()
	{
		super();

		persistentDraw = persistentUpdate = true;
		destroySubStates = false;

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('Options_Buttons');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(950, 30 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " idle", 24, true);
			menuItem.animation.addByPrefix('select', optionShit[i] + " select", 24, true);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.scrollFactor.x = 0;
			menuItem.scrollFactor.y = 1;

			menuItem.x = 2000;
			FlxTween.tween(menuItem, {x: 800}, 0.15, {ease: FlxEase.expoInOut});
		}

		var nTex = Paths.getSparrowAtlas('Options_Navigation');
		navi = new FlxSprite();
		navi.frames = nTex;
		navi.animation.addByPrefix('arrow', "navigation_arrows", 24, true);
		navi.animation.addByPrefix('enter', "navigation_enter", 24, true);
		navi.animation.addByPrefix('shiftArrow', "navigation_shiftArrow", 24, true);
		navi.animation.play('arrow');
		navi.scrollFactor.set();
		add(navi);
		navi.y = 700 - navi.height;
		navi.x = 1260 - navi.width;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		changeItem();

		createResults();

		updateResults();

		FlxG.camera.follow(camFollow, null, camLerp);

		DiscordClient.changePresence("Settings page: General", null);

                #if android
		addVirtualPad(FULL, A_B);
		#end
	}

	function createResults():Void
	{
		add(ResultText);
		ResultText.scrollFactor.x = 0;
		ResultText.scrollFactor.y = 0;
		ResultText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
		ResultText.x = -400;
		ResultText.y = 350;
		ResultText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		ResultText.alpha = 0;
		FlxTween.tween(ResultText, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});

		add(ExplainText);
		ExplainText.scrollFactor.x = 0;
		ExplainText.scrollFactor.y = 0;
		ExplainText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
		ExplainText.alignment = LEFT;
		ExplainText.x = 20;
		ExplainText.y = 624;
		ExplainText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		ExplainText.alpha = 0;
		FlxTween.tween(ExplainText, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});
	}

	function updateResults():Void
	{
		switch (_variables.filter)
		{
			case 'none':
				fil = 0;
			case 'tritanopia':
				fil = 1;
			case 'protanopia':
				fil = 2;
			case 'deutranopia':
				fil = 3;
			case 'virtual boy':
				fil = 4;
			case 'gameboy':
				fil = 5;
			case 'downer':
				fil = 6;
			case 'grayscale':
				fil = 7;
			case 'invert':
				fil = 8;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				changeItem(1);
			}

			if (controls.LEFT_P)
			{
				changeStuff(-1);
			}

			if (controls.RIGHT_P)
			{
				changeStuff(1);
			}

			if (controls.LEFT)
			{
				changeHold(-1);
			}
	
			if (controls.RIGHT)
			{
				changeHold(1);
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), _variables.svolume / 100);
				selectedSomethin = true;

				DiscordClient.changePresence("Back to the main menu I go!", null);

				menuItems.forEach(function(spr:FlxSprite)
				{
					spr.animation.play('idle');
					FlxTween.tween(spr, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
				});

				FlxTween.tween(FlxG.camera, {zoom: 7}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.2});
				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					FlxG.switchState(new MainMenuState());
				});
			}
		}

		switch (optionShit[curSelected])
		{
			case "resolution":
				ResultText.text = FlxG.width * _variables.resolution + "x" + FlxG.height * _variables.resolution;
				ExplainText.text = "RESOLUTION:\nChange the resolution of your game.";
			case "fullscreen":
				ResultText.text = Std.string(_variables.fullscreen).toUpperCase();
				ExplainText.text = "FULLSCREEN:\nMake your game stretch to your entire screen.";
			case "fpsCounter":
				ResultText.text = Std.string(_variables.fpsCounter).toUpperCase();
				ExplainText.text = "FPS COUNTER:\nToggle your FPS counter on or off.";
			case "fps":
				ResultText.text = _variables.fps + " FPS";
				ExplainText.text = "FPS CAP:\nChange your FPS cap when you want some smoother footage.";
			case "page":
				ResultText.text = "";
				ExplainText.text = "Previous Page: CLEAR \nNext Page: SFX";
			case "filter":
				ResultText.text = _variables.filter;
				ExplainText.text = "FILTER: \nChange how colors of the game work, either for fun or if you're colorblind.";
			case "brightness":
				ResultText.text = _variables.brightness / 2 + "%";
				ExplainText.text = "BRIGHTNESS: \nChange how bright your game looks.";
			case "gamma":
				ResultText.text = _variables.gamma / 1 * 100 + "%";
				ExplainText.text = "GAMMA: \nChange how vibrant your game looks.";
			case "memory":
				ResultText.text = Std.string(_variables.memory).toUpperCase();
				ExplainText.text = "MEMORY: \nSee how your memory's acting in game.";
			case "watermark":
				ResultText.text = Std.string(_variables.watermark).toUpperCase();
				ExplainText.text = "WATERMARK: \nSwitch your watermark on or off.";
			case "hue":
				ResultText.text = Std.string(_variables.hue);
				ExplainText.text = "HUE: \nChange the hues of your game's colors.";
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.scale.set(FlxMath.lerp(spr.scale.x, 0.5, camLerp / (_variables.fps / 60)), FlxMath.lerp(spr.scale.y, 0.5, 0.4 / (_variables.fps / 60)));

			if (spr.ID == curSelected)
			{
				camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp / (_variables.fps / 60));
				camFollow.x = spr.getGraphicMidpoint().x;
				spr.scale.set(FlxMath.lerp(spr.scale.x, 0.9, camLerp / (_variables.fps / 60)), FlxMath.lerp(spr.scale.y, 0.9, 0.4 / (_variables.fps / 60)));
			}

			spr.updateHitbox();
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('select');
			}

			spr.updateHitbox();
		});

		switch (optionShit[curSelected])
		{
			case 'resolution'|'fps'|'brightness'|'gamma'|'hue':
				navi.animation.play('shiftArrow');
			default:
				navi.animation.play('arrow');
		}
	}

	function changeStuff(Change:Int = 0)
	{
		switch (optionShit[curSelected])
		{
			case "resolution":
				if (controls.CENTER)
					Change *= 2;

				_variables.resolution += FlxMath.roundDecimal(Change / 5, 4);
				if (_variables.resolution < 0.2)
					_variables.resolution = 0.2;

				Lib.application.window.maximized = false;
				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				FlxG.resizeWindow(Math.round(FlxG.width * _variables.resolution), Math.round(FlxG.height * _variables.resolution));

				FlxG.fullscreen = false;
				FlxG.fullscreen = _variables.fullscreen;
			case "fullscreen":
				Lib.application.window.maximized = false;
				_variables.fullscreen = !_variables.fullscreen;

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				FlxG.fullscreen = _variables.fullscreen;
			case "fpsCounter":
				_variables.fpsCounter = !_variables.fpsCounter;

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				Main.toggleFPS(_variables.fpsCounter);
			case "memory":
				_variables.memory = !_variables.memory;

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				Main.toggleMem(_variables.memory);
			case "watermark":
				_variables.watermark = !_variables.watermark;

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				Main.watermark.visible = _variables.watermark;
			case "fps":
				if (controls.CENTER)
					Change *= 2;

				_variables.fps += 10 * Change;
				if (_variables.fps < 60)
					_variables.fps = 60;
				if (_variables.fps > 120)
					_variables.fps = 120;

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					FlxG.updateFramerate = _variables.fps;
					FlxG.drawFramerate = _variables.fps;
				}); // it was prone to skip certain values so I had to put it in a timer
			case 'page':
				SettingsState.page += Change;
				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				selectedSomethin = true;

				menuItems.forEach(function(spr:FlxSprite)
				{
					spr.animation.play('idle');
					FlxTween.tween(spr, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
				});

				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					navi.kill();
					menuItems.kill();
					if (Change == 1)
						openSubState(new PAGE2settings());
					else
						openSubState(new PAGE6settings());
				});
			case "filter":
				fil += Change;
				if (fil > 8)
					fil = 0;
				if (fil < 0)
					fil = 8;

				switch (fil)
				{
					case 0:
						_variables.filter = 'none';
					case 1:
						_variables.filter = 'tritanopia';
					case 2:
						_variables.filter = 'protanopia';
					case 3:
						_variables.filter = 'deutranopia';
					case 4:
						_variables.filter = 'virtual boy';
					case 5:
						_variables.filter = 'gameboy';
					case 6:
						_variables.filter = 'downer';
					case 7:
						_variables.filter = 'grayscale';
					case 8:
						_variables.filter = 'invert';
				}

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				MainVariables.UpdateColors();
			case "brightness":
				if (controls.CENTER)
					Change *= 2;

				_variables.brightness += Change * 10;
				if (_variables.brightness < -200)
					_variables.brightness = -200;
				if (_variables.brightness > 200)
					_variables.brightness = 200;

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				MainVariables.UpdateColors();
			case "gamma":
				if (controls.CENTER)
					Change *= 2;

				_variables.gamma += FlxMath.roundDecimal(Change / 10, 2);
				if (_variables.gamma < 0.1)
					_variables.gamma = 0.1;
				if (_variables.gamma > 5)
					_variables.gamma = 5;

				_variables.gamma = FlxMath.roundDecimal(_variables.gamma, 2);

				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				MainVariables.UpdateColors();
		}

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			MainVariables.Save();
		});
	}

	function changeHold(Change:Int = 0)
		{
			if (controls.CENTER)
				Change *= 2;
	
			switch (optionShit[curSelected])
			{
				case "hue":
					_variables.hue += Change;
					if (_variables.hue < 0)
						_variables.hue = 359;
					if (_variables.hue > 359)
						_variables.hue = 0;
	
				FlxG.sound.play(Paths.sound('scrollMenu'), _variables.svolume / 100);
				MainVariables.UpdateColors();
			}
	
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				MainVariables.Save();
			});
		}

	override function openSubState(SubState:FlxSubState)
	{
		super.openSubState(SubState);
	}
}
