package test {
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import flash.events.InvokeEvent;
    import flash.desktop.NativeApplication;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import flash.net.URLLoader;

    public class test extends Application {

        public function test() {
            addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
            flash.desktop.NativeApplication.nativeApplication.addEventListener(
                "invoke", onInvoke );
        }

        private function creationCompleteHandler( event:FlexEvent ):void {
        }

        private function onInvoke( event:InvokeEvent ):void {
            try {
                trace( event.currentDirectory.url );
                var $file:File = event.currentDirectory.resolvePath( "t/assets/BFBC2/GameSettings.ini" );
                var $stream:FileStream = new FileStream();

                $stream.open( $file, FileMode.READ );
                var $content:String = $stream.readUTFBytes( $stream.bytesAvailable );
                $stream.close();
                $content = $content.replace( new RegExp( File.lineEnding, "g" ), "\n" );
                $stream.close();
                
                trace( $content );
            }
            catch ( $error:Error ) {
                trace( $error.message );
            }
            flash.desktop.NativeApplication.nativeApplication.exit( 0 );
        }
    }
}
