package test {
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import flash.events.InvokeEvent;
    import flash.desktop.NativeApplication;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;

    public class test extends Application {

        public function test() {
            addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
            flash.desktop.NativeApplication.nativeApplication.addEventListener(
                "invoke", onInvoke );
        }

        private function creationCompleteHandler( event:FlexEvent ):void {
        }

        private function onInvoke( event:Object ):void {
            var $file:File = File.userDirectory.resolvePath( "xyzzy" );
            var $fileStream:FileStream = new FileStream();
            $fileStream.open( $file, FileMode.WRITE );
            $fileStream.close();
            flash.desktop.NativeApplication.nativeApplication.exit( 0 );
        }
    }
}
