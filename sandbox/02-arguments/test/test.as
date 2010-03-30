package test {
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import flash.events.InvokeEvent;
    import flash.desktop.NativeApplication;

    public class test extends Application {

        public function test() {
            addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
            flash.desktop.NativeApplication.nativeApplication.addEventListener(
                "invoke", onInvoke );
        }

        private function creationCompleteHandler( event:FlexEvent ):void {
            trace( "Hello, World." );
        }

        private function onInvoke( event:Object ):void {
            trace( "Arguments: " + event.arguments );
        }

    }
}
