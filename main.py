from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.floatlayout import FloatLayout
from kivy.clock import Clock
from kivy.animation import Animation
from datetime import datetime

class MyApp(App):
    def build(self):
        self.layout = FloatLayout()

        self.greeting_label = Label(
            text="Hello, this is my first phone app!",
            font_size='24sp',
            size_hint=(.8, .2),
            pos_hint={'center_x': 0.5, 'top': 1}
        )

        self.time_label = Label(
            text=self.get_time(),
            font_size='32sp',
            size_hint=(.4, .2),
        )

        # Initially place it off-screen to the left
        self.time_label.x = -500
        self.time_label.center_y = self.layout.center_y

        self.layout.add_widget(self.greeting_label)
        self.layout.add_widget(self.time_label)

        Clock.schedule_interval(self.update_time, 1)

        self.time_visible = False
        self.layout.bind(on_touch_down=self.toggle_time)

        return self.layout

    def get_time(self):
        return datetime.now().strftime("%H:%M:%S")

    def update_time(self, dt):
        self.time_label.text = self.get_time()

    def toggle_time(self, *args):
        if self.time_visible:
            # Slide out to the left
            anim = Animation(x=-500, duration=0.5)
            self.time_visible = False
        else:
            # Slide into center
            center_x = (self.layout.width - self.time_label.width) / 2
            anim = Animation(x=center_x, duration=0.5)
            self.time_visible = True

        anim.start(self.time_label)

if __name__ == "__main__":
    MyApp().run()