# How to use EasyMenu

Using EasyMenu is rather ... easy, especially if you are already familiar with Godot as it uses the same name for nodes. Note though that not all nodes are available. But before that, how do we get the executable?

## Building EasyMenu

Building EasyMenu isn't too difficult. Open the project in Godot and export the project. One piece of advice is to use a minimum build of Godot to keep the exported project size small as we only need the control nodes and none of the 2D and 3D stuff.

## Creating the config file

Just go to the main folder where you would normally run your build commands from and create a file called `easy_menu.conf`. Inside of this file you add all the details in order of which you want to make them appear in.

You will notice some properties being used for all nodes, so here's a quick breakdown of them.
- title: This is for the text people will see for what the setting is for;
- key: This is for the commands executed by buttons, if you name a key `test`, you can use that variable inside of a command with `{test}`;
- arg: Want the command not just to have the value? Set the arg to whatever you like, but remember to include `{value}` in it like in this example `platform={}`. Could be helpful to set for when you have an option to leave it blank;
- tooltip: This will give a popup when people hover over the menu in which you can give more info of what that specific setting does;
- default: The default value, for things like SpinBox this is not called default but value instead;

### Comments

To place comments in the file, start the line with a `#`. As simple as that and to make it easier for people to 

### Header blocks

A header block is what I call the parts such as `[ TITLE ]`, text between brackets. For some examples you can go to [https://github.com/voylin/easy_menu/blob/master/examples](https://github.com/voylin/easy_menu/blob/master/examples) but here is a quick rundown of all possibilities and available nodes.

#### Settings

The settings is where you can set the window title and size. You can put it anywhere in the file, but recommended on top for visability

Can be created by `[ Settings ]`.

Properties:
- window_title;
- window_width;
- window_height;

#### Title

A title is some centered text you can use to divide different parts of your menu.

Can be created by `[ Title ]`.

Properties:
- title;
- tooltip;

#### HSeparator

In case you want a line dividing different sections of the menu, you can use the separator. This is the only one which does not accept any variables as it is ... well, just a line.

Can be created by `[ HSeparator ]`.

#### SpinBox

A spinbox allows users to select a number, you can set the default value by setting the value property and make it clamp between min_value and max_value.

Can be created by `[ SpinBox ]`.

Properties:
- title;
- key;
- arg;
- tooltip;
- value;
- min_value;
- max_value;

#### OptionButton

The OptionButton is probably one of the more usefull nodes to add, it does have a lot of properties but should be pretty straightforward to work with. For the values and option, the position in the array matters. If values isn't defined, then the text from the option menu itself will be used.

Can be created by `[ OptionButton ]`.

Properties:
- title;
- key;
- arg;
- tooltip
- options;
- values;
- default;

#### LineEdit

A LineEdit gives the freedom to make people put their own text.

Can be created by `[ LineEdit ]`.

Properties:
- title;
- key;
- arg;
- tooltip;
- default;

#### CheckButton

For `yes` and `no` arguments, the strings these can give can be setup with the properties `on_true` and `on_false`.

Can be created by `[ CheckButton ]`.

Properties:
- title;
- key;
- arg;
- tooltip;
- on_true;
- on_false;

#### Button

Buttons are used to run commands, you can add arguments by surounding them in `{}` with the defined key in it (lower case). Note that these commands will run from where the file is located. You can define the command in cmd.

Can be created by `[ Button ]`.

Properties:
- title;
- cmd;

