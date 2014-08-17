package flixel.system.render.genome2d 
{
	import com.genome2d.context.GContextConfig;
	import com.genome2d.context.IContext;
	import com.genome2d.Genome2D;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTexture;
	import flash.geom.Rectangle;
	import flixel.FlxG;
	import flixel.FlxGame;
	import flixel.system.render.FlxRender;
	
	/**
	 * TODO: add docs
	 * 
	 * Tutorial from: http://blog.flash-core.com/?p=3132
	 * 
	 * @author Dovyski
	 */
	public class FlxGenome2DRender extends FlxRender
	{
		[Embed(source="../../../../../../../Testing/src/Ground.png")] private var TexturePNG:Class;
		
		private var texture:GTexture;
		private var genome:Genome2D;
		private var startGameCallback:Function;
		
		public function FlxGenome2DRender(Game:FlxGame, StartGameCallback:Function) 
		{
			super(Game, StartGameCallback);
			
			var config:GContextConfig = new GContextConfig(Game.stage, new Rectangle(0,0,Game.stage.stageWidth,Game.stage.stageHeight));
			 
			// Initialize Genome2D
			genome = Genome2D.getInstance();
			genome.onInitialized.addOnce(genomeInitializedHandler);
			genome.init(config);
			
			startGameCallback = StartGameCallback;
		}
		
		private function genomeInitializedHandler():void
		{
			// We will create a single texture from an embedded bitmap
			texture = GTextureFactory.createFromEmbedded("texture", TexturePNG);
			
			// Add a callback into the rendering pipeline
			genome.onPreRender.add(preRenderHandler);
			
			startGameCallback();
		}
		
		private function preRenderHandler():void
		{
			var context:IContext = genome.getContext();
			context.draw(texture, 50, 50);
			//FlxG.log("working?" + FlxG.random.float());
		}
	}
}