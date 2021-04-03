import 'package:flutter/material.dart';
import 'package:pref/pref.dart';

class MySetting extends StatefulWidget {

  @override
  _MySettingState createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
      ),
      body: PrefPage(
        children: [
          PrefTitle(title: Text('General')),
          PrefDropdown<String>(
            title: Text('Start Page'),
            pref: 'start_page',
            items: [
              DropdownMenuItem(value: 'Home', child: Icon(Icons.home)),
              DropdownMenuItem(value: 'Timeline', child: Icon(Icons.timeline)),
              DropdownMenuItem(value: 'Messages', child: Icon(Icons.message)),
            ],
          ),
          PrefDropdown<String>(
            title: Text('Number of items'),
            pref: 'items_count',
            // fullWidth: false,
            items: [
              DropdownMenuItem(value: 'qrcode', child: Text('QR Code')),
              DropdownMenuItem(value: '2', child: Text('Two')),
              DropdownMenuItem(value: '3', child: Text('Three')),
              DropdownMenuItem(value: '4', child: Text('Four')),
            ],
          ),
          PrefTitle(title: Text('Personalization')),
          PrefRadio<String>(
            title: Text('System Theme'),
            value: 'system',
            pref: 'ui_theme',
          ),
          PrefRadio<String>(
            title: Text('Light Theme'),
            value: 'light',
            pref: 'ui_theme',
          ),
          PrefRadio(
            title: Text('Dark Theme'),
            value: 'dark',
            pref: 'ui_theme',
          ),
          PrefTitle(title: Text('Messaging')),
          PrefPageButton(
            title: Text('Notifications'),
            leading: Icon(Icons.message),
            trailing: Icon(Icons.keyboard_arrow_right),
            page: PrefPage(
              cache: true,
              children: [
                PrefTitle(title: Text('New Posts')),
                PrefSwitch(
                  title: Text('New Posts from Friends'),
                  pref: 'notification_newpost_friend',
                ),
                PrefTitle(title: Text('Private Messages')),
                PrefSwitch(
                  title: Text('Private Messages from Friends'),
                  pref: 'notification_pm_friend',
                ),
                PrefSwitch(
                  title: Text('Private Messages from Strangers'),
                  pref: 'notification_pm_stranger',
                  onChange: (value) async {
                    print('notification_pm_stranger changed to: $value');
                  },
                ),
              ],
            ),
          ),
          PrefTitle(title: Text('User')),
          PrefText(
            label: 'Display Name',
            pref: 'user_display_name',
          ),
          PrefText(
            label: 'E-Mail',
            pref: 'user_email',
            validator: (str) {
              if (str == null || !str.endsWith('@gmail.com')) {
                return 'Invalid email';
              }
              return null;
            },
          ),
          PrefButtonGroup<int>(
            title: Text('Gender'),
            pref: 'gender',
            items: [
              ButtonGroupItem(value: 1, child: Text('Male')),
              ButtonGroupItem(value: 2, child: Text('Female')),
              ButtonGroupItem(value: 3, child: Text('Other')),
            ],
          ),
          PrefSlider<int>(
            title: Text('Your age'),
            pref: 'age',
            trailing: (num v) => SizedBox(width: 50, child: Text('I\'m $v')),
            min: 10,
            max: 90,
          ),
          PrefLabel(
            title: Text(
              PrefService.of(context).get<String>('user_description') ?? '',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          PrefDialogButton(
            title: Text('Edit description'),
            dialog: PrefDialog(
              children: [
                PrefText(
                  label: 'Description',
                  pref: 'user_description',
                  padding: EdgeInsets.only(top: 8.0),
                  autofocus: true,
                  maxLines: 2,
                )
              ],
              title: Text('Edit description'),
              cancel: Text('Cancel'),
              submit: Text('Save'),
            ),
            onPop: () => setState(() {}),
          ),
          PrefTitle(title: Text('Content')),
          PrefDialogButton(
            title: Text('Content Types'),
            dialog: PrefDialog(
              children: [
                PrefCheckbox(
                  title: Text('Text'),
                  pref: 'content_show_text',
                ),
                PrefCheckbox(
                  title: Text('Images'),
                  pref: 'content_show_image',
                ),
                PrefCheckbox(
                  title: Text('Music'),
                  pref: 'content_show_audio',
                )
              ],
              title: Text('Enabled Content Types'),
              cancel: Icon(Icons.cancel),
              submit: Icon(Icons.save),
            ),
          ),
          PrefButton(
            child: Text('Delete'),
            onTap: () => print('DELETE!'),
            color: Colors.red,
          ),
          PrefTitle(title: Text('More Dialogs')),
          PrefChoice<String>(
            title: Text('Android\'s "ListPreference"'),
            pref: 'android_listpref_selected',
            items: [
              DropdownMenuItem(value: 'select_1', child: Text('Select me!')),
              DropdownMenuItem(value: 'select_2', child: Text('Hello World!')),
              DropdownMenuItem(value: 'select_3', child: Text('Test')),
            ],
            cancel: Text('Cancel'),
          ),
          PrefDialogButton(
            title: Text('Android\'s "ListPreference" with autosave'),
            dialog: PrefDialog(
              children: [
                PrefRadio(
                  title: Text('Select me!'),
                  value: 'select_1',
                  pref: 'android_listpref_auto_selected',
                ),
                PrefRadio(
                  title: Text('Hello World!'),
                  value: 'select_2',
                  pref: 'android_listpref_auto_selected',
                ),
                PrefRadio(
                  title: Text('Test'),
                  value: 'select_3',
                  pref: 'android_listpref_auto_selected',
                ),
              ],
              title: Text('Select an option'),
              submit: Text('Close'),
            ),
          ),
          PrefDialogButton(
            title: Text('Android\'s "MultiSelectListPreference"'),
            dialog: PrefDialog(
              children: [
                PrefCheckbox(
                  title: Text('A enabled'),
                  pref: 'android_multilistpref_a',
                ),
                PrefCheckbox(
                  title: Text('B enabled'),
                  pref: 'android_multilistpref_b',
                ),
                PrefCheckbox(
                  title: Text('C enabled'),
                  pref: 'android_multilistpref_c',
                ),
              ],
              title: Text('Select multiple options'),
              cancel: Text('Cancel'),
              submit: Text('Save'),
            ),
          ),
          PrefTitle(title: Text('Advanced')),
          PrefCheckbox(
            title: Text('Enable Advanced Features'),
            pref: 'advanced_enabled',
            onChange: (value) {
              setState(() {});
              if (!value) {
                PrefService.of(context).set('exp_showos', false);
              }
            },
          ),
          PrefHider(
            pref: 'advanced_enabled',
            children: [
              PrefSwitch(
                title: Text('Show Operating System'),
                pref: 'exp_showos',
                subtitle: Text(
                    'This option shows the users operating system in his profile'),
              )
            ],
          ),
        ],
      ),
    );
  }
}