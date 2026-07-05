// 修复点1：改为默认导入 getContext
import getContext from '@ohos.app.ability.common';
import { preferences } from '@kit.ArkData';

@Entry
@Component
struct Index {
  @State inputText: string = ''
  @State todos: string[] = []
  @State bgColor: string = '#FFFFFF'
  @State isNightMode: boolean = false

  private PREF_NAME: string = 'TodoListData'
  private KEY_TODOS: string = 'todos_key'
  private KEY_BG_COLOR: string = 'bg_color_key'
  private KEY_NIGHT_MODE: string = 'night_mode_key'

  aboutToAppear() {
    this.loadData()
    this.loadBgColor()
    this.loadNightMode()
    this.applyTheme()
  }

  async loadData() {
    try {
      const pref = await preferences.getPreferences(getContext(this), this.PREF_NAME)
      const jsonStr = await pref.get(this.KEY_TODOS, '') as string
      if (jsonStr !== '') {
        this.todos = JSON.parse(jsonStr)
      }
    } catch (e) {
      console.error('读取数据失败：' + (e as Error).message)
    }
  }

  async saveData() {
    try {
      const pref = await preferences.getPreferences(getContext(this), this.PREF_NAME)
      await pref.put(this.KEY_TODOS, JSON.stringify(this.todos))
      await pref.flush()
    } catch (e) {
      console.error('保存数据失败：' + (e as Error).message)
    }
  }

  async loadBgColor() {
    try {
      const pref = await preferences.getPreferences(getContext(this), this.PREF_NAME)
      const color = await pref.get(this.KEY_BG_COLOR, '#FFFFFF') as string
      this.bgColor = color
    } catch (e) {
      console.error('读取背景色失败：' + (e as Error).message)
    }
  }

  async saveBgColor(color: string) {
    try {
      const pref = await preferences.getPreferences(getContext(this), this.PREF_NAME)
      await pref.put(this.KEY_BG_COLOR, color)
      await pref.flush()
      this.bgColor = color
    } catch (e) {
      console.error('保存背景色失败：' + (e as Error).message)
    }
  }

  async loadNightMode() {
    try {
      const pref = await preferences.getPreferences(getContext(this), this.PREF_NAME)
      const mode = await pref.get(this.KEY_NIGHT_MODE, false) as boolean
      this.isNightMode = mode
    } catch (e) {
      console.error('读取深夜模式失败：' + (e as Error).message)
    }
  }

  async saveNightMode(mode: boolean) {
    try {
      const pref = await preferences.getPreferences(getContext(this), this.PREF_NAME)
      await pref.put(this.KEY_NIGHT_MODE, mode)
      await pref.flush()
      this.isNightMode = mode
      this.applyTheme()
    } catch (e) {
      console.error('保存深夜模式失败：' + (e as Error).message)
    }
  }

  applyTheme() {
    if (this.isNightMode) {
      this.bgColor = '#1A1A1A'
    } else {
      this.bgColor = '#FFFFFF'
    }
  }

  addTodo() {
    if (this.inputText.trim() !== '') {
      this.todos.push(this.inputText)
      this.inputText = ''
      this.saveData()
    }
  }

  removeTodo(index: number) {
    this.todos.splice(index, 1)
    this.saveData()
  }

  @Builder
  MenuBuilder() {
    Column() {
      Row() {
        Text('深夜模式')
          .fontSize(16)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.isNightMode })
          .onChange((isOn: boolean) => {
            this.saveNightMode(isOn)
          })
      }
      .width('100%')
      .padding(10)

      Divider().margin({ top: 5, bottom: 5 })

      Button('红色背景')
        .width('100%')
        .backgroundColor('#FF6B6B')
        .fontColor(Color.White)
        .onClick(() => {
          this.saveBgColor('#FF6B6B')
        })
      Button('绿色背景')
        .width('100%')
        .backgroundColor('#51CF66')
        .fontColor(Color.White)
        .onClick(() => {
          this.saveBgColor('#51CF66')
        })
      Button('蓝色背景')
        .width('100%')
        .backgroundColor('#4DABF7')
        .fontColor(Color.White)
        .onClick(() => {
          this.saveBgColor('#4DABF7')
        })
    }
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow(10)
  }

  build() {
    Column() {
      Row() {
        Text('我的待办')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .fontColor(this.isNightMode ? '#E0E0E0' : Color.Black)

        Button('⋮')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Transparent)
          .fontColor(this.isNightMode ? '#E0E0E0' : Color.Black)
          .bindMenu(this.MenuBuilder)
      }
      .width('100%')
      .margin({ bottom: 20 })

      Row() {
        TextInput({ placeholder: '输入要做的事...' })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.inputText = value
          })
          .margin({ right: 10 })
          .backgroundColor(this.isNightMode ? '#333333' : Color.White)
          .fontColor(this.isNightMode ? '#E0E0E0' : Color.Black)
          .placeholderColor(this.isNightMode ? '#888888' : '#999999')

        Button('添加')
          .onClick(() => {
            this.addTodo()
          })
          .backgroundColor(this.isNightMode ? '#444444' : Color.Blue)
          .fontColor(this.isNightMode ? '#E0E0E0' : Color.White)
      }
      .width('100%')
      .margin({ bottom: 20 })

      List() {
        ForEach(this.todos, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .layoutWeight(1)
                .fontSize(18)
                .fontColor(this.isNightMode ? '#E0E0E0' : Color.Black)

              Button('删除')
                .fontSize(14)
                .backgroundColor(Color.Red)
                .fontColor(Color.White)
                .onClick(() => {
                  this.removeTodo(index)
                })
            }
            .width('100%')
            .padding(10)
            .borderRadius(8)
            .backgroundColor(this.isNightMode ? '#2A2A2A' : '#f5f5f5')
            .margin({ bottom: 8 })
          }
        })
      }
      .width('100%')
      .height('100%') // 修复点2：显式设置高度，消除警告
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.bgColor)
    .animation({ duration: 300 })
  }
}