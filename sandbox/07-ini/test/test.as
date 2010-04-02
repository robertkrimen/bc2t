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
                var $section:SectionLine;
                $content.split( "\n" ).forEach( function( $item:*, $index:int, $array:Array ):void {
                    var $result:Array;
                    if      ( ( $result = $item.match( /^\s*\[([^\]]+)\]/ ) ) ) {
                        $section = new SectionLine( $item, $result[0] );
                    }
                    else if ( ( $result = $item.match( /^\s*([^=]+)=\s*(.*)/ ) ) ) {
                        var $parameter:ParameterLine = new ParameterLine( $item, $result[0], $result[1] );
                    }
                    else if ( ( $result = $item.match( /^\s*$/ ) ) )  {
                    }
                    else if ( ( $result = $item.match( /^\s*[;#](.*)$/ ) ) )  {
                        var $comment:CommentLine = new CommentLine( $item, $result[0] );
                    }
                    else {
                        trace( $item );
                    }
                } );
                $stream.close();
            }
            catch ( $error:Error ) {
                trace( $error.message );
            }
            flash.desktop.NativeApplication.nativeApplication.exit( 0 );
        }
    }

}

class INI {
}

class SectionLine {

    public var name:String;
    public var comment:String;

    private var _$line:String;

    public function SectionLine( $line:String, $name:String ) {
        _$line = $line;
        name = $name;
    }
}

class ParameterLine {

    public var key:String;
    public var value:String;
    public var comment:String;

    private var _$line:String;

    public function ParameterLine( $line:String, $key:String, $remainder:String ) {
        _$line = $line;
        key = $key;

        var $result:Array;
        if      ( ( $result = $remainder.match( /^"(.*)"(?:\s*[^;#](.*))?\s*$/ ) ) ) {
            value = $result[0];
            comment = $result[1];
        }
        else if ( ( $result = $remainder.match( /^([^#;\s]*)(?:\s*[^;#](.*))?\s*$/ ) ) ) {
            value = $result[0];
            comment = $result[1];
        }
        else if ( ( $result = $remainder.match( /^\s*[^;#](.*)\s*$/ ) ) ) {
            comment = $result[0];
        }
        else {
            value = null;
        }
    }
}

class CommentLine {

    public var comment:String;

    private var _$line:String;

    public function CommentLine( $line:String, $comment:String ) {
        _$line = $line;
        comment = $comment;
    }
}
