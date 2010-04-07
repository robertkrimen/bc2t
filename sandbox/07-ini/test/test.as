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
            var $ini:INI = new INI();
            try {
                trace( event.currentDirectory.url );
                var $file:File;
                $file = event.currentDirectory.resolvePath( "t/assets/BFBC2/GameSettings.ini" );
                $file = event.currentDirectory.resolvePath( "t/assets/t0.ini" );
                var $stream:FileStream = new FileStream();

                $stream.open( $file, FileMode.READ );
                var $content:String = $stream.readUTFBytes( $stream.bytesAvailable );
                $stream.close();
                $content = $content.replace( new RegExp( File.lineEnding, "g" ), "\n" );
                $content.split( "\n" ).forEach( function( $item:*, $index:int, $array:Array ):void {
                    var $result:Array;
                    if      ( ( $result = $item.match( /^\s*\[([^\]]+)\]/ ) ) ) {
                        var $section:SectionLine = new SectionLine( $item, $result[1] );
                        $ini.addSection( $section );
                    }
                    else if ( ( $result = $item.match( /^\s*([^=]+)=\s*(.*)/ ) ) ) {
                        var $parameter:ParameterLine = new ParameterLine( $item, $result[1], $result[2] );
                        $ini.addParameter( $parameter );
                    }
                    else if ( ( $result = $item.match( /^\s*$/ ) ) )  {
                    }
                    else if ( ( $result = $item.match( /^\s*[;#](.*)$/ ) ) )  {
                        var $comment:CommentLine = new CommentLine( $item, $result[1] );
                        $ini.addComment( $comment );
                    }
                    else {
                        trace( $item );
                    }
                } );
                $stream.close();
            }
            catch ( $error:Error ) {
                trace( $error.message );
                $ini = null;
                throw $error;
            }

            if ( $ini ) {
                trace( $ini.get( "Apple" ) );
                trace( $ini.get( "Banana" ) );
                trace( $ini.get( "Cherry" ) );
                trace( $ini );
            }
            flash.desktop.NativeApplication.nativeApplication.exit( 0 );
        }
    }

}

class INI {

    private var _$lastSectionLine:SectionLine;
    private var _$lineList:Array = [];
    private var _$index:Object = {};

    public function INI() {
    }

    public function get( $key:String ):String {
        var $entry:* = this.entry( $key );
        return $entry ? $entry.value : "";
    }

    public function entry( $key:String ):Object {
        return _$index[ $key ];
    }

    public function addSection( $line:SectionLine ):void {
        _$lineList.push( $line );
        _$lastSectionLine = $line;
    }

    public function addParameter( $line:ParameterLine ):void {
        if ( ! _$lastSectionLine )
            throw new Error( "Parameter line before section line: " + $line.key );
        _$lastSectionLine.addParameter( $line );
        _$index[ $line.key ] = $line;
        _$index[ _$lastSectionLine.name + "/" + $line.key ] = $line;
    }

    public function addComment( $line:CommentLine ):void {
        if ( ! _$lastSectionLine )
            _$lineList.push( $line );
        else
            _$lastSectionLine.addComment( $line );
    }

    public function toString():String {
        return _$lineList.join( "\n" );
    }
}


class INILine {
}

class SectionLine extends INILine {

    public var name:String;
    public var comment:String;

    private var _$line:String;
    private var _$lineList:Array = [];

    public function SectionLine( $line:String, $name:String ) {
        _$line = $line;
        name = $name;
    }

    public function addParameter( $line:ParameterLine ):void {
        $line.section = this;
        _$lineList.push( $line );
    }

    public function addComment( $line:CommentLine ):void {
        $line.section = this;
        _$lineList.push( $line );
    }

    public function toString():String {
        return "[" + name + "]" + "\n" +
            _$lineList.join( "\n" );
    }
}

class ParameterLine extends INILine {

    public var key:String;
    public var value:String;
    public var comment:String;
    public var section:SectionLine;
    public var quoted:Boolean = false;

    private var _$line:String;

    public function ParameterLine( $line:String, $key:String, $remainder:String ) {
        _$line = $line;
        key = $key;

        var $result:Array;
        if      ( ( $result = $remainder.match( /^"(.*)"(?:\s*[^;#](.*))?\s*$/ ) ) ) {
            value = $result[1];
            comment = $result[2];
            quoted = true;
        }
        else if ( ( $result = $remainder.match( /^([^#;\s]*)(?:\s*[^;#](.*))?\s*$/ ) ) ) {
            value = $result[1];
            comment = $result[2];
        }
        else if ( ( $result = $remainder.match( /^\s*[^;#](.*)\s*$/ ) ) ) {
            comment = $result[1];
        }
        else {
            value = null;
        }
    }

    public function toString():String {
        var $value:String = value;
        if ( quoted || $value.match( /\s/ ) ) {
            $value = "\"" + $value + "\"";
        }
        return key + " = " + $value;
    }
}

class CommentLine extends INILine {

    public var comment:String;
    public var section:SectionLine;

    private var _$line:String;

    public function CommentLine( $line:String, $comment:String ) {
        _$line = $line;
        comment = $comment;
    }

    public function toString():String {
        return ";" + comment;
    }
}
