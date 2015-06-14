package flixel.util
{
    /**
     * TODO: Write documentation
     *
     * @author moly
     * @author greysondn
     */
    public class FlxObjectPool
    {
        protected var _objects:Array;
        protected var _objectClass:Class;
        
        public function FlxObjectPool(ObjectClass:Class)
        {
            _objectClass = ObjectClass;
            _objects     = new Array();
        }
        
        public function getNew():*
        {
            var object:* = null;
            
            if (_objects.length > 0)
            {
                object = _objects.pop();
            }
            else
            {
                object = new _objectClass();
            }
            
            return object;
        }
        
        public function disposeObject(OldObject:Object):void
        {
            _objects.push(OldObject);
        }
    }
}
