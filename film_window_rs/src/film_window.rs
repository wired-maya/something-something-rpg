use godot::classes::class_macros::private::virtuals::Xrvrs::Side;
use godot::classes::node::InternalMode;
use godot::classes::tween::{EaseType, TransitionType};
use godot::obj::{BaseMut, Singleton};
use godot::prelude::*;
use godot::classes::{Control, Engine, IPanel, Panel, StyleBox, ThemeDb, Tween};
use crate::anim_data_types::*;

// TODO: Use RustCallable
#[derive(GodotClass)]
#[class(base = Panel, tool)]
pub struct FilmWindow {
    base: Base<Panel>,

    // region: Exported Variables

    // Group of properties that correspond to the animations used after updating window sizing
    // The offset tweens correspond to animating the offsets of the content container and shadow rects
    #[export_group(name = "Tweening", prefix = "tween_")]

    #[export] pub tween_buffer_mode: TweenBufferMode,

    #[export_subgroup(name = "Do Offset Tweens", prefix = "do_tween_offset_")]
    #[export] pub do_tween_offset_change: bool,
    #[export] pub do_tween_offset_enter: bool,
    #[export] pub do_tween_offset_exit: bool,

    #[export_subgroup(name = "On Enter/Window Size", prefix = "tween_window_enter_")]
    #[export] pub tween_window_enter_transition: TransitionType,
    #[export] pub tween_window_enter_easing: EaseType,
    #[export] pub tween_window_enter_delay: f64,
    #[export] pub tween_window_enter_duration: f64,

    #[export_subgroup(name = "On Enter/Style Box Offsets", prefix = "tween_offset_enter_")]
    #[export] pub tween_offset_enter_transition: TransitionType,
    #[export] pub tween_offset_enter_easing: EaseType,
    #[export] pub tween_offset_enter_delay: f64,
    #[export] pub tween_offset_enter_duration: f64,

    #[export_subgroup(name = "On Enter", prefix = "tween_enter_")]
    #[export] pub tween_enter_anchor: Vector2,

    #[export_subgroup(name = "On Change/Window Size", prefix = "tween_window_change_")]
    #[export] pub tween_window_change_transition: TransitionType,
    #[export] pub tween_window_change_easing: EaseType,
    #[export] pub tween_window_change_delay: f64,
    #[export] pub tween_window_change_duration: f64,

    #[export_subgroup(name = "On Change/Style Box Offsets", prefix = "tween_offset_change_")]
    #[export] pub tween_offset_change_transition: TransitionType,
    #[export] pub tween_offset_change_easing: EaseType,
    #[export] pub tween_offset_change_delay: f64,
    #[export] pub tween_offset_change_duration: f64,

    #[export_subgroup(name = "On Change", prefix = "tween_change_")]
    #[export] pub tween_change_anchor: Vector2,

    #[export_subgroup(name = "On Exit/Window Size", prefix = "tween_window_exit_")]
    #[export] pub tween_window_exit_transition: TransitionType,
    #[export] pub tween_window_exit_easing: EaseType,
    #[export] pub tween_window_exit_delay: f64,
    #[export] pub tween_window_exit_duration: f64,

    #[export_subgroup(name = "On Exit/Style Box Offsets", prefix = "tween_offset_exit_")]
    #[export] pub tween_offset_exit_transition: TransitionType,
    #[export] pub tween_offset_exit_easing: EaseType,
    #[export] pub tween_offset_exit_delay: f64,
    #[export] pub tween_offset_exit_duration: f64,

    #[export_subgroup(name = "On Exit", prefix = "tween_exit_")]
    #[export] pub tween_exit_anchor: Vector2,

    // endregion

    // region: Private Variables

    // Ref counter stored so passing down the functions or repeated calls to .to_gd() aren't necessary
    this: OnReady<Gd<FilmWindow>>,

    enter_on_ready: bool,

    content_container_style_box: Option<Gd<StyleBox>>,
    content_container_rect: Rect2,
    content_container_offset: Vector2,

    shadow_style_box: Option<Gd<StyleBox>>,
    shadow_rect: Rect2,
    shadow_offset: Vector2,

    tween: Option<Gd<Tween>>,

    // These are set later, uses Default::default() for now
    // TODO: Getters and setters?
    tween_window_enter_info: Gd<TweenInfo>,
    tween_offset_enter_info: Gd<TweenInfo>,

    tween_window_change_info: Gd<TweenInfo>,
    tween_offset_change_info: Gd<TweenInfo>,

    tween_window_exit_info: Gd<TweenInfo>,
    tween_offset_exit_info: Gd<TweenInfo>,

    clipping_control: Gd<Control>,

    child_pos_offset: Vector2,
    child_size_offset: Vector2,

    // endregion

    // region: Callables

    start_clipping_callable: Callable,
    stop_clipping_callable: Callable,
    move_control_preserve_rect_global_callable: Callable,

    // endregion
}

#[godot_api]
impl IPanel for FilmWindow {
    fn init(base: Base<Panel>) -> Self {
        // Defaults
        Self {
            base,

            tween_buffer_mode: TweenBufferMode::Ignore,

            do_tween_offset_change: true,
            do_tween_offset_enter: true,
            do_tween_offset_exit: true,

            // TODO: Constants, to make sure above and below values are synced
            tween_window_enter_transition: TransitionType::CUBIC,
            tween_window_enter_easing: EaseType::IN,
            tween_window_enter_delay: 0.35,
            tween_window_enter_duration: 0.35,

            tween_offset_enter_transition: TransitionType::SINE,
            tween_offset_enter_easing: EaseType::OUT,
            tween_offset_enter_delay: 0.0,
            tween_offset_enter_duration: 0.1,

            tween_enter_anchor: Vector2::new(1.0, 1.0),

            tween_window_change_transition: TransitionType::CUBIC,
            tween_window_change_easing: EaseType::IN,
            tween_window_change_delay: 0.0,
            tween_window_change_duration: 0.3,

            tween_offset_change_transition: TransitionType::SINE,
            tween_offset_change_easing: EaseType::OUT,
            tween_offset_change_delay: 0.0,
            tween_offset_change_duration: 0.15,

            tween_change_anchor: Vector2::new(0.5, 0.5),

            tween_window_exit_transition: TransitionType::CUBIC,
            tween_window_exit_easing: EaseType::OUT,
            tween_window_exit_delay: 0.0,
            tween_window_exit_duration: 0.3,

            tween_offset_exit_transition: TransitionType::SINE,
            tween_offset_exit_easing: EaseType::IN,
            tween_offset_exit_delay: 0.0,
            tween_offset_exit_duration: 0.15,

            tween_exit_anchor: Vector2::new(0.0, 0.0),

            this: OnReady::manual(),

            enter_on_ready: true,

            content_container_style_box: None,
            content_container_rect: Rect2::new(Vector2::ZERO, Vector2::new(100.0, 100.0)),
            content_container_offset: Vector2::ZERO,

            shadow_style_box: None,
            shadow_rect: Rect2::new(Vector2::ZERO, Vector2::new(100.0, 100.0)),
            shadow_offset: Vector2::ZERO,

            tween: None,

            tween_window_enter_info: Default::default(),
            tween_offset_enter_info: Default::default(),

            tween_window_change_info: Default::default(),
            tween_offset_change_info: Default::default(),

            tween_window_exit_info: Default::default(),
            tween_offset_exit_info: Default::default(),

            clipping_control: Control::new_alloc(), // TODO: Always present, so remove checks

            child_pos_offset: Vector2::ZERO,
            child_size_offset: Vector2::ZERO,

            start_clipping_callable: Callable::from_fn("tween_start_clipping", |val| {
                Self::start_clipping(val[0].to());
            }),
            stop_clipping_callable: Callable::from_fn("stop_clipping", |val| {
                Self::stop_clipping(val[0].to());
            }),
            move_control_preserve_rect_global_callable: Callable::from_fn("move_control_preserve_rect_global", |val| {
                Self::move_control_preserve_rect_global(val[0].to(), val[1].to(), val[2].to());
            }),
        }
    }

    fn ready(&mut self) {
        self.this.init(self.to_gd());

        // Make sure there is a theme loaded
        // Theme is loaded from this
        // if let Some(theme) = ThemeDb::singleton().get_project_theme() {
        //     self.base_mut().set_theme(&theme);
        // }

        self.on_resized(); // Handle appearance in editor

        // TODO: Create a default theme if this fails
        self.base_mut().set_theme(&ThemeDb::singleton().get_project_theme().unwrap());
        self.load_theme(); // Signal doesn't get fired if set in ready

        // Needs this theme type until a custom theme can be set up
        // self.base_mut().set_theme_type_variation("FilmWindow");

        self.tween_info_update();

        let mut tween: Gd<Tween> = self.base_mut().create_tween().set_parallel();
        tween.stop();
        self.tween = Some(tween);

        if !Engine::singleton().is_editor_hint() {
            self.on_child_order_changed();
            if self.enter_on_ready {
                self.do_tween_enter(
                    Callable::from_fn("pass", |_| { })
                );
            }
        }
    }

    fn draw(&mut self) {
        // TODO: Is there a way to draw the style boxes with continuous animations while not touching the rect?
	    // TODO: For example if you wanted the shadow to spin slowly

        // Taking is zero cost, compared to cloning the styleboxes each draw call
        let shadow_ref: Gd<StyleBox> = self.shadow_style_box.take().unwrap();
        let shadow_rect: Rect2 = self.shadow_rect;
        self.base_mut().draw_style_box(&shadow_ref, shadow_rect);

        let content_container_ref: Gd<StyleBox> = self.content_container_style_box.take().unwrap();
        let content_container_rect: Rect2 = self.content_container_rect;
        self.base_mut().draw_style_box(&content_container_ref, content_container_rect);

        // Move back in so all unwraps succeed
        self.shadow_style_box = Some(shadow_ref);
        self.content_container_style_box = Some(content_container_ref);
    }

    // Ensure you can resize however you want
    fn get_minimum_size(&self) -> Vector2 { Vector2::ZERO }
}

#[godot_api]
impl FilmWindow {
    // region: Signals

    // Signals at every stage of animation for further animations
    // Coordinates are all global
    #[signal] pub fn tween_content_container_changed(window: Gd<FilmWindow>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_content_container_changed_start(window: Gd<FilmWindow>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_content_container_changed_end(window: Gd<FilmWindow>, state: Gd<RectState>, tween: Gd<TweenInfo>);

    #[signal] pub fn tween_shadow_changed(window: Gd<FilmWindow>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_shadow_changed_start(window: Gd<FilmWindow>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_shadow_changed_end(window: Gd<FilmWindow>, state: Gd<RectState>, tween: Gd<TweenInfo>);

    #[signal] pub fn tween_window_changed(window: Gd<FilmWindow>, content_container_state: Gd<RectState>, shadow_state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_window_changed_start(window: Gd<FilmWindow>, content_container_state: Gd<RectState>, shadow_state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_window_changed_end(window: Gd<FilmWindow>, content_container_state: Gd<RectState>, shadow_state: Gd<RectState>, tween: Gd<TweenInfo>);

    #[signal] pub fn tween_offset_changed(window: Gd<FilmWindow>, content_container_state: Gd<RectState>, shadow_state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_offset_changed_start(window: Gd<FilmWindow>, content_container_state: Gd<RectState>, shadow_state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_offset_changed_end(window: Gd<FilmWindow>, content_container_state: Gd<RectState>, shadow_state: Gd<RectState>, tween: Gd<TweenInfo>);

    // Delay is the smallest between the window size and shadow offset delays, which is to say it's the delay to any animations starting
    // Similarly, duration is the total duration for all actions to finish
    #[signal] pub fn tween_entered(window: Gd<FilmWindow>, window_content_container_state: Gd<RectState>, window_shadow_state: Gd<RectState>, window_tween: Gd<TweenInfo>, offset_content_container_state: Gd<RectState>, offset_shadow_state: Gd<RectState>, offset_tween: Gd<TweenInfo>, delay: f64, duration: f64);
    #[signal] pub fn tween_changed(window: Gd<FilmWindow>, window_content_container_state: Gd<RectState>, window_shadow_state: Gd<RectState>, window_tween: Gd<TweenInfo>, offset_content_container_state: Gd<RectState>, offset_shadow_state: Gd<RectState>, offset_tween: Gd<TweenInfo>, delay: f64, duration: f64);
    #[signal] pub fn tween_exited(window: Gd<FilmWindow>, window_content_container_state: Gd<RectState>, window_shadow_state: Gd<RectState>, window_tween: Gd<TweenInfo>, offset_content_container_state: Gd<RectState>, offset_shadow_state: Gd<RectState>, offset_tween: Gd<TweenInfo>, delay: f64, duration: f64);

    // Signals for tweening clipping control
    #[signal] pub fn tween_clipping_control_changed(control: Gd<Control>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_clipping_control_changed_start(control: Gd<Control>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_clipping_control_changed_end(control: Gd<Control>, state: Gd<RectState>, tween: Gd<TweenInfo>);

    // Signals for tweening the child controls
    #[signal] pub fn tween_content_control_changed(control: Gd<Control>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_content_control_changed_start(control: Gd<Control>, state: Gd<RectState>, tween: Gd<TweenInfo>);
    #[signal] pub fn tween_content_control_changed_end(control: Gd<Control>, state: Gd<RectState>, tween: Gd<TweenInfo>);

    // Handle different types of signals
    fn get_signal_emit_callable(signal: Signal, varargs: Vec<Variant>) -> Callable {
        let name: String = signal.name().to_string();
        Callable::from_fn(name, move |_| {
            signal.emit(&varargs);
        })
    }

    // TODO: Since these are static, can they be implemented on the type alias?
    // TODO: Either way, move them out to anim_data_types.rs
    fn get_signal_emit_callable_anim_component(
        signal: AnimComponentSignal,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) -> Callable {
        let signal: Signal = signal.to_untyped();
        let this: Gd<Object> = signal.object().expect("Signal needs to be connected to an object to be fired");
        Callable::from_fn("emit_anim_component_signal", move |_| {
            signal.emit(&[this.to_variant(), rect_state.to_variant(), tween_info.to_variant()]);
        })
    }

    fn signal_emit_anim_component(
        signal: AnimComponentSignal,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) {
        let signal: Signal = signal.to_untyped();
        let this: Gd<Object> = signal.object().expect("Signal needs to be connected to an object to be fired");
        signal.emit(&[this.to_variant(), rect_state.to_variant(), tween_info.to_variant()]);
    }

    fn get_signal_emit_callable_anim_control(
        signal: AnimControlSignal,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) -> Callable {
        let signal: Signal = signal.to_untyped();
        let this: Gd<Object> = signal.object().expect("Signal needs to be connected to an object to be fired");
        Callable::from_fn("emit_anim_control_signal", move |_| {
            signal.emit(&[this.to_variant(), rect_state.to_variant(), tween_info.to_variant()]);
        })
    }

    fn signal_emit_anim_control(
        signal: AnimControlSignal,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) {
        let signal: Signal = signal.to_untyped();
        let this: Gd<Object> = signal.object().expect("Signal needs to be connected to an object to be fired");
        signal.emit(&[this.to_variant(), rect_state.to_variant(), tween_info.to_variant()]);
    }

    fn get_signal_emit_callable_anim(
        signal: AnimSignal,
        content_control_state: Gd<RectState>,
        shadow_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) -> Callable {
        let signal: Signal = signal.to_untyped();
        let this: Gd<Object> = signal.object().expect("Signal needs to be connected to an object to be fired");
        Callable::from_fn("emit_anim_signal", move |_| {
            signal.emit(&[this.to_variant(), content_control_state.to_variant(), shadow_state.to_variant(), tween_info.to_variant()]);
        })
    }

    fn signal_emit_anim(
        signal: AnimSignal,
        content_control_state: Gd<RectState>,
        shadow_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) {
        let signal: Signal = signal.to_untyped();
        let this: Gd<Object> = signal.object().expect("Signal needs to be connected to an object to be fired");
        signal.emit(&[this.to_variant(), content_control_state.to_variant(), shadow_state.to_variant(), tween_info.to_variant()]);
    }

    // endregion

    // region: Initialization

    // Returns a FilmWindow with the initial state provided
    // If enter_on_ready is false, the enter function must be called later
    // If enter_on_ready is true, must provide new_rect
    #[func] pub fn from_props(enter_on_ready: bool, new_rect: Rect2) -> Gd<Self> {
        todo!()
    }

    // TODO: Remember to call at the start of each top level tween function
    fn tween_info_update(&mut self) {
        let tween_window_enter_info: Gd<TweenInfo> = TweenInfo::from(
            self.tween_window_enter_transition,
            self.tween_window_enter_easing,
            self.tween_window_enter_delay,
            self.tween_window_enter_duration,
        );
        let tween_offset_enter_info: Gd<TweenInfo> = TweenInfo::from(
            self.tween_offset_enter_transition,
            self.tween_offset_enter_easing,
            self.tween_offset_enter_delay,
            self.tween_offset_enter_duration,
        );

        let tween_window_change_info: Gd<TweenInfo> = TweenInfo::from(
            self.tween_window_change_transition,
            self.tween_window_change_easing,
            self.tween_window_change_delay,
            self.tween_window_change_duration,
        );
        let tween_offset_change_info: Gd<TweenInfo> = TweenInfo::from(
            self.tween_offset_change_transition,
            self.tween_offset_change_easing,
            self.tween_offset_change_delay,
            self.tween_offset_change_duration,
        );

        let tween_window_exit_info: Gd<TweenInfo> = TweenInfo::from(
            self.tween_window_exit_transition,
            self.tween_window_exit_easing,
            self.tween_window_exit_delay,
            self.tween_window_exit_duration,
        );
        let tween_offset_exit_info: Gd<TweenInfo> = TweenInfo::from(
            self.tween_offset_exit_transition,
            self.tween_offset_exit_easing,
            self.tween_offset_exit_delay,
            self.tween_offset_exit_duration,
        );
        
        self.tween_window_enter_info = tween_window_enter_info;
        self.tween_offset_enter_info = tween_offset_enter_info;

        self.tween_window_change_info = tween_window_change_info;
        self.tween_offset_change_info = tween_offset_change_info;

        self.tween_window_exit_info = tween_window_exit_info;
        self.tween_offset_exit_info = tween_offset_exit_info;
    }

    // endregion

    // region: Callbacks

    fn on_theme_changed(&mut self) { self.load_theme() }

    // Better not to resize when using as a class, use change function
    fn on_resized(&mut self) {
        if Engine::singleton().is_editor_hint() {
            let size: Vector2 = self.base().get_size();

            self.content_container_rect.size = size;
            self.shadow_rect.size = size;

            self.on_child_order_changed();
        }
    }

    fn on_child_order_changed(&mut self) {
        let size: Vector2 = self.base().get_size();
        let pos_offset: Vector2 = self.child_pos_offset;
        let size_offset: Vector2 = self.child_size_offset;
        let clipping_control: Gd<Control> = self.clipping_control.clone(); // Gd is smart pointer

        let base: BaseMut<'_, FilmWindow> = self.base_mut();

        for child in base.get_children().iter_shared() {
            if let Ok(mut control) = child.try_cast::<Control>() {
                control.set_position(pos_offset);
                control.set_size(size - pos_offset + size_offset);

                if clipping_control.is_node_ready() {
                    control.reparent_ex(&clipping_control).keep_global_transform(false).done();
                }
            }
        }
    }

    // endregion

    // region: Drawing

    // TODO: Need to find a way to handle no style box being present
    fn load_theme(&mut self) {
        let size: Vector2 = self.base().get_size();

        // TODO: WARNING: CURRENTLY UNWRAPS, EXPECT PANICS!
        let content_container_style_box: Gd<StyleBox> = self.base().get_theme_stylebox("content_container").unwrap();
        let content_container_offset: Vector2 = Vector2::new(
            self.base().get_theme_constant("content_container_offset_x") as f32,
            self.base().get_theme_constant("content_container_offset_y") as f32,
        );
        
        self.content_container_style_box = Some(content_container_style_box);
        self.content_container_offset = content_container_offset;
        self.content_container_rect.position = content_container_offset;
        self.content_container_rect.size = size;

        // TODO: WARNING: CURRENTLY UNWRAPS, EXPECT PANICS!
        let shadow_style_box: Gd<StyleBox> = self.base().get_theme_stylebox("shadow").unwrap();
        let shadow_offset: Vector2 = Vector2::new(
            self.base().get_theme_constant("shadow_offset_x") as f32,
            self.base().get_theme_constant("shadow_offset_y") as f32,
        );

        // Update margins
        self.child_pos_offset = Vector2::new(
            shadow_style_box.get_content_margin(Side::LEFT),
            shadow_style_box.get_content_margin(Side::TOP),
        );
        self.child_size_offset = Vector2::new(
            -shadow_style_box.get_content_margin(Side::RIGHT),
            -shadow_style_box.get_content_margin(Side::BOTTOM),
        );

        self.shadow_offset = shadow_offset;
        self.shadow_rect.position = shadow_offset;
        self.shadow_rect.size = size;
        self.shadow_style_box = Some(shadow_style_box);
    }

    fn start_clipping(mut window: Gd<FilmWindow>) {
        let control: Gd<Control> = window.bind().clipping_control.clone();
        window.add_child_ex(&control)
            .force_readable_name(false).internal(InternalMode::FRONT).done();

        for mut child in window.get_children().iter_shared() {
            child.reparent_ex(&control).keep_global_transform(false).done();
        }
    }

    fn stop_clipping(mut window: Gd<FilmWindow>) {
        let mut control: Gd<Control> = window.bind().clipping_control.clone();

        for mut child in window.get_children().iter_shared() {
            child.reparent_ex(&window).keep_global_transform(false).done();
        }

        // Clean up control
        window.bind_mut().clipping_control = Control::new_alloc();
        control.queue_free();
    }

    // Moves the window control to the new rect while adjusting other rects by offset so they stay in place
    fn move_control_preserve_rect_global(new_rect: Rect2, pos_diff: Vector2, mut window: Gd<FilmWindow>) {
        // Apply difference to children
        for child in window.get_children().iter_shared() {
            if let Ok(mut control) = child.try_cast::<Control>() {
                let pos = control.get_position();

                control.set_position(pos - pos_diff);
            }
        }

        window.set_position(new_rect.position);
        window.set_size(new_rect.size);
    }

    #[func]
    pub fn tween_method_content_container(val: Rect2, mut window: Gd<FilmWindow>) {
        window.bind_mut().content_container_rect = val;
        window.queue_redraw(); // Ran only once a frame, therefore it's fine to call multiple times during tween
    }

    #[func]
    pub fn tween_method_shadow(val: Rect2, mut window: Gd<FilmWindow>) {
        window.bind_mut().shadow_rect = val;
        window.queue_redraw(); // Ran only once a frame, therefore it's fine to call multiple times during tween
    }

    // Tweens content with offsets, useful for clipping and resizing with only the window size rects
    #[func]
    pub fn tween_method_control(
        mut val: Rect2,
        mut item: Gd<Control>,
        pos_offset: Vector2,
        size_offset: Vector2,
    ) {
        val.position += pos_offset;
        val.size += -pos_offset + size_offset;

        // Do not grow unless there is space for it
        if val.size.x < 0.0 { val.size.x = 0.0 }
        if val.size.y < 0.0 { val.size.y = 0.0 }

        item.set_position(val.position);
	    item.set_size(val.size);
    }

    // endregion

    // region: Tween Functions

    // TODO: Update comment
    // Base function for tweening rects managed by this window
    // Signals can be null, but if present they must have the following arguments:
    // signal_changed(cur_rect: Rect2, final_rect: Rect2, trans: Tween.TransitionType, _ease: Tween.EaseType, duration: float)
    //  Signal is emitted when this function is called
    // signal_start(cur_rect: Rect2, final_rect: Rect2, trans: Tween.TransitionType, _ease: Tween.EaseType, duration: float)
    //	Signal is emitted when the tween begins
    // signal_end(final_rect: Rect2)
    //	Signal is emitted when the tween ends
    fn do_tween_rect(
        &mut self,
        method_func: Callable,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>,
        signal_changed: AnimComponentSignal,
        signal_start: AnimComponentSignal,
        signal_end: AnimComponentSignal,
    ) {
        {
            let rect_state_bind: GdRef<'_, RectState> = rect_state.bind();
            let tween_info_bind: GdRef<'_, TweenInfo> = tween_info.bind();

            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
                .set_trans(tween_info_bind.trans_type)
                .set_ease(tween_info_bind.ease_type);

            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_method(
                &method_func.bind(&[self.this.to_variant()]),
                &rect_state_bind.start.to_variant(),
                &rect_state_bind.end.to_variant(),
                tween_info_bind.duration
            ).set_delay(tween_info_bind.delay);
        }

        let start_callback: Callable = Self::get_signal_emit_callable_anim_component(signal_start, rect_state.clone(), tween_info.clone());
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_callback(&start_callback).set_delay(tween_info.bind().delay);

        let end_callback: Callable = Self::get_signal_emit_callable_anim_component(signal_end, rect_state.clone(), tween_info.clone());
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_callback(&end_callback).set_delay(tween_info.bind().delay);

        Self::signal_emit_anim_component(signal_changed, rect_state, tween_info);
    }

    // Tweens controls, similar to do_tween_rect but with offset handling and signals that give references to controls
    fn do_tween_control(
        &mut self,
        control: Gd<Control>,
        pos_offset: Vector2,
        size_offset: Vector2,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>,
        signal_changed: AnimControlSignal,
        signal_start: AnimControlSignal,
        signal_end: AnimControlSignal,
    ) {
        {
            let rect_state_bind: GdRef<'_, RectState> = rect_state.bind();
            let tween_info_bind: GdRef<'_, TweenInfo> = tween_info.bind();
            let method: Callable = self.base().callable("tween_method_control");

            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
                .set_trans(tween_info_bind.trans_type)
                .set_ease(tween_info_bind.ease_type);

            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_method(
                &method.bind(&[
                    control.to_variant(), pos_offset.to_variant(), size_offset.to_variant()
                ]),
                &rect_state_bind.start.to_variant(),
                &rect_state_bind.end.to_variant(),
                tween_info_bind.duration
            ).set_delay(tween_info_bind.delay);
        }

        let start_callback: Callable = Self::get_signal_emit_callable_anim_control(signal_start, rect_state.clone(), tween_info.clone());
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_callback(&start_callback).set_delay(tween_info.bind().delay);

        let end_callback: Callable = Self::get_signal_emit_callable_anim_control(signal_end, rect_state.clone(), tween_info.clone());
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_callback(&end_callback).set_delay(tween_info.bind().delay);

        Self::signal_emit_anim_control(signal_changed, rect_state, tween_info);
    }

    // Tween the container's location to a given rect with the appropriate offsets
    fn do_tween_content_container(
        &mut self,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) {
        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows

        let tween_content_container_changed: AnimComponentSignal = this.signals().tween_content_container_changed().__typed;
        let tween_content_container_changed_start: AnimComponentSignal = this.signals().tween_content_container_changed_start().__typed;
        let tween_content_container_changed_end: AnimComponentSignal = this.signals().tween_content_container_changed_end().__typed;

        let method: Callable = self.base().callable("tween_method_content_container");

        self.do_tween_rect(
            method,
            rect_state,
            tween_info,
            tween_content_container_changed,
            tween_content_container_changed_start,
            tween_content_container_changed_end,
        );
    }

    fn do_tween_shadow(
        &mut self,
        rect_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>
    ) {
        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows

        let tween_shadow_changed: AnimComponentSignal = this.signals().tween_shadow_changed().__typed;
        let tween_shadow_changed_start: AnimComponentSignal = this.signals().tween_shadow_changed_start().__typed;
        let tween_shadow_changed_end: AnimComponentSignal = this.signals().tween_shadow_changed_end().__typed;

        let method: Callable = self.base().callable("tween_method_shadow");

        self.do_tween_rect(
            method,
            rect_state,
            tween_info,
            tween_shadow_changed,
            tween_shadow_changed_start,
            tween_shadow_changed_end,
        );
    }

    fn do_tween_rects(
        &mut self,
        content_container_state: Gd<RectState>,
        shadow_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>,
        signal_changed: AnimSignal,
        signal_start: AnimSignal,
        signal_end: AnimSignal,
    ) {
        self.do_tween_content_container(content_container_state.clone(), tween_info.clone());
        self.do_tween_shadow(shadow_state.clone(), tween_info.clone());

        let start_callback: Callable = Self::get_signal_emit_callable_anim(signal_start, content_container_state.clone(), shadow_state.clone(), tween_info.clone());
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_callback(&start_callback).set_delay(tween_info.bind().delay);

        let end_callback: Callable = Self::get_signal_emit_callable_anim(signal_end, content_container_state.clone(), shadow_state.clone(), tween_info.clone());
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change").tween_callback(&end_callback).set_delay(tween_info.bind().delay);

        Self::signal_emit_anim(signal_changed, content_container_state, shadow_state, tween_info);
    }

    // Calls chain on tween at the end
    fn do_tween_offsets(
        &mut self,
        tween_offset_motion: TweenOffsetMotion,
        content_container_from: Rect2,
        shadow_from: Rect2,
        tween_info: Gd<TweenInfo>,
    ) {
        let mut offset_content_container_rect_state: RectState = RectState {
            start: content_container_from, end: content_container_from
        };
        let mut offset_shadow_rect_state: RectState = RectState {
            start: shadow_from, end: shadow_from
        };

        match tween_offset_motion {
            TweenOffsetMotion::Apart => {
                offset_content_container_rect_state.end.position += self.content_container_offset;
                offset_shadow_rect_state.end.position += self.shadow_offset;
            }
            TweenOffsetMotion::Together => {
                offset_content_container_rect_state.end.position -= self.content_container_offset;
                offset_shadow_rect_state.end.position -= self.shadow_offset;
            },
        }

        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows

        let tween_offset_changed: AnimSignal = this.signals().tween_offset_changed().__typed;
        let tween_offset_changed_start: AnimSignal = this.signals().tween_offset_changed_start().__typed;
        let tween_offset_changed_end: AnimSignal = this.signals().tween_offset_changed_end().__typed;

        self.do_tween_rects(
            Gd::from_object(offset_content_container_rect_state),
            Gd::from_object(offset_shadow_rect_state),
            tween_info,
            tween_offset_changed,
            tween_offset_changed_start,
            tween_offset_changed_end
        );
    }

    // Starts clipping, clipping must be stopped manually afterwards
    fn do_tween_clipping_control(
        &mut self,
        content_container_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>,
        clip_mode: TweenClipMode,
    ) {
        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows

        let tween_clipping_control_changed: AnimControlSignal = this.signals().tween_clipping_control_changed().__typed;
        let tween_clipping_control_changed_start: AnimControlSignal = this.signals().tween_clipping_control_changed_start().__typed;
        let tween_clipping_control_changed_end: AnimControlSignal = this.signals().tween_clipping_control_changed_end().__typed;

        self.do_tween_control(
            self.clipping_control.clone(),
            self.child_pos_offset,
            self.child_size_offset,
            content_container_state.clone(),
            tween_info.clone(),
            tween_clipping_control_changed,
            tween_clipping_control_changed_start,
            tween_clipping_control_changed_end
        );

        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
            .tween_callback(&self.start_clipping_callable.bind(&[self.this.to_variant()]));

        let mut child_size: Vector2 = self.child_size_offset - self.child_pos_offset;

        // TODO: Reduce binds
        match clip_mode {
            TweenClipMode::ClipCurrentSize => { child_size += content_container_state.bind().start.size },
            TweenClipMode::ClipFinalSize => { child_size += content_container_state.bind().end.size },
            TweenClipMode::Stretch => (), // Used elsewhere
        }

        // Since children are passed as references, this can be ran before reparenting
        for child in self.base().get_children().iter_shared() {
            if child.is_class("Control") {
                self.do_tween_control(
                    // Since it's a child of the clipping rect, it is already offset
                    self.clipping_control.clone(),
                    Vector2::ZERO,
                    Vector2::ZERO,
                    RectState::from(
                        Rect2 {
                            // Keep it relative to FilmWindow
                            position: -content_container_state.bind().start.position,
                            size: child_size
                        },
                        Rect2 {
                            position: -content_container_state.bind().end.position,
                            size: child_size
                        },
                    ),
                    tween_info.clone(),
                    this.signals().tween_content_control_changed().__typed,
                    this.signals().tween_content_control_changed_start().__typed,
                    this.signals().tween_content_control_changed_end().__typed
                );
            }
        }
    }

    fn do_tween_window_size(
        &mut self,
        content_container_state: Gd<RectState>,
        shadow_state: Gd<RectState>,
        tween_info: Gd<TweenInfo>,
        clip_mode: TweenClipMode,
    ) {
        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows

        let tween_window_changed: AnimSignal = this.signals().tween_window_changed().__typed;
        let tween_window_changed_start: AnimSignal = this.signals().tween_window_changed_start().__typed;
        let tween_window_changed_end: AnimSignal = this.signals().tween_window_changed_end().__typed;

        self.do_tween_rects(
            content_container_state.clone(),
            shadow_state,
            tween_info.clone(),
            tween_window_changed,
            tween_window_changed_start,
            tween_window_changed_end
        );

        if clip_mode == TweenClipMode::Stretch {
            for child in self.base().get_children().iter_shared() {
                if child.is_class("Control") {
                    self.do_tween_control(
                        child.cast(),
                        self.child_pos_offset,
                        self.child_size_offset,
                        content_container_state.clone(),
                        tween_info.clone(),
                        this.signals().tween_content_control_changed().__typed,
                        this.signals().tween_content_control_changed_start().__typed,
                        this.signals().tween_content_control_changed_end().__typed
                    );
                }
            }
        } else {
            self.do_tween_clipping_control(
                content_container_state,
                tween_info,
                clip_mode
            );
        }
    }

    // Resize/move the window to the new rect
    // TODO: Add buffering or don't run if an animation is happening
    // TODO: Move chain commands here instead of other tween funcs
    fn do_tween_change(
        &mut self,
        new_rect: Rect2, // Because these represent a state, they do not need to be referenced
        tween_window_info: Gd<TweenInfo>,
        tween_offset_info: Gd<TweenInfo>,
        tween_offset_mode: TweenOffsetMode, // Consumed in this function, hence no Gd
        callback: Callable, // Callback for entire animation, hence is consumed here
        clip_mode: TweenClipMode, // Passed down without need for multiple references
        mut tween_signal: AnimWindowSignal, // Consumed here
    ) {
        // TODO: Switch all arguments to Gd so you can easily pass between functions

        // TODO: Do I need this?
        if self.tween != None {
            if self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
                .is_running() { return };
            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
                .kill();
        }

        let tween: Gd<Tween> = self.base_mut().create_tween().set_parallel();
        self.tween = Some(tween);

        let window_control_rect_pos_diff: Vector2 = new_rect.position - self.base().get_position();

        // Update positions when tweening begins, so the update is drawn at the same time as the rects
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
            .tween_callback(&self.move_control_preserve_rect_global_callable.bind(&[new_rect.to_variant(), window_control_rect_pos_diff.to_variant(), self.this.to_variant()]));

        // Update rects so tweening calculations are from the correct place
        self.content_container_rect.position -= window_control_rect_pos_diff;
        self.shadow_rect.position -= window_control_rect_pos_diff;

        let mut window_content_container_state: RectState = RectState {
            start: self.content_container_rect,
            end: Rect2 { position: Vector2::ZERO, size: new_rect.size },
        };
        let mut window_shadow_state: RectState = RectState {
            start: self.shadow_rect,
            end: Rect2 { position: Vector2::ZERO, size: new_rect.size },
        };

        if tween_offset_mode == TweenOffsetMode::None {
            window_content_container_state.end.position = self.content_container_offset;
            window_shadow_state.end.position = self.shadow_offset;
        } else {
            window_content_container_state.start.position -= self.content_container_offset;
            window_shadow_state.start.position -= self.shadow_offset;
        }

        if tween_offset_mode == TweenOffsetMode::Both || tween_offset_mode == TweenOffsetMode::Before {
            self.do_tween_offsets(
                TweenOffsetMotion::Together,
                self.content_container_rect,
                self.shadow_rect,
                tween_offset_info.clone(),
            );

            // End of offset tween
            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
                .chain();
        }

        // Allows ownership to cleanly be consumed by do_tween_window_size
        let stop_clip: bool = clip_mode == TweenClipMode::ClipCurrentSize || clip_mode == TweenClipMode::ClipFinalSize;

        self.do_tween_window_size(
            Gd::from_object(window_content_container_state.clone()),
            Gd::from_object(window_shadow_state.clone()),
            tween_window_info.clone(),
            clip_mode,
        );

        // End of window size tween
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
            .chain();

        // Tween clipping must be de-initialized manually
        if stop_clip {
            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
                .tween_callback(&self.stop_clipping_callable.bind(&[self.this.to_variant()]));
        }

        let mut offset_content_container_state: RectState = RectState {
            start: self.content_container_rect,
            end: window_content_container_state.end,
        };
        let mut offset_shadow_state: RectState = RectState {
            start: self.shadow_rect,
            end: window_shadow_state.end,
        };

        if tween_offset_mode == TweenOffsetMode::Both || tween_offset_mode == TweenOffsetMode::After {
            self.do_tween_offsets(
                TweenOffsetMotion::Apart,
                window_content_container_state.end,
                window_shadow_state.end,
                tween_offset_info.clone(),
            );

            // End of offset tween
            self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
                .chain();

            offset_content_container_state.end.position += self.content_container_offset;
            offset_shadow_state.end.position += self.shadow_offset;
        }

        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
            .tween_callback(&callback);

        // This marks the end of the change animation tween
        self.tween.as_deref_mut().expect("Tween needs to be initialized in do_tween_change")
            .chain();

        // Calculate info for signal
        // TODO: Check if it's more efficient to have f32 or f64 with Godot
        let total_delay: f64;
        if tween_offset_mode == TweenOffsetMode::Both || tween_offset_mode == TweenOffsetMode::Before {
            total_delay = tween_offset_info.bind().delay;
        } else {
            total_delay = tween_window_info.bind().delay;
        }

        // TODO: REDUCE BINDS!!!
        let mut total_duration: f64 = tween_window_info.bind().delay + tween_window_info.bind().duration;
        let offset_duration: f64 = tween_offset_info.bind().delay + tween_offset_info.bind().duration;

        if tween_offset_mode == TweenOffsetMode::Both {
            total_duration += offset_duration * 2.0;
        }
        if tween_offset_mode == TweenOffsetMode::Before || tween_offset_mode == TweenOffsetMode::After {
            total_duration += offset_duration;
        }

        tween_signal.emit_tuple(
            (
                self.to_gd(),

                Gd::from_object(window_content_container_state),
                Gd::from_object(window_shadow_state),
                tween_window_info,

                Gd::from_object(offset_content_container_state),
                Gd::from_object(offset_shadow_state),
                tween_offset_info,

                total_delay,
                total_duration,
            )
        );
    }

    fn do_tween_enter(&mut self, callback: Callable) {
        let window_rect_state: RectState = RectState {
            start: Rect2 {
                position: self.base().get_position() + (self.tween_enter_anchor * self.base().get_size()),
                size: Vector2::ZERO,
            },
            end: self.base().get_rect(),
        };

        // Make sure the content is hidden at first
        for child in self.base_mut().get_children().iter_shared() {
            if child.is_class("Control") {
                child.cast::<Control>().set_size(Vector2::ZERO);
            }
        }

        // Initial window rect
        self.base_mut().set_position(window_rect_state.start.position);
        self.base_mut().set_size(window_rect_state.start.size);

        // Enter hidden 
        self.content_container_rect = Rect2 { position: self.content_container_offset, size: Vector2::ZERO };
        self.shadow_rect = Rect2 { position: self.shadow_offset, size: Vector2::ZERO };

        let tween_offset_mode: TweenOffsetMode;
        if self.do_tween_offset_enter { tween_offset_mode = TweenOffsetMode::After }
        else { tween_offset_mode = TweenOffsetMode::None }

        let window_enter_info: Gd<TweenInfo> = self.tween_window_enter_info.clone();
        let offset_enter_info: Gd<TweenInfo> = self.tween_offset_enter_info.clone();

        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows
        let signal: AnimWindowSignal = this.signals().tween_entered().__typed;

        self.do_tween_change(
            window_rect_state.end,
            window_enter_info,
            offset_enter_info,
            tween_offset_mode,
            callback,
            TweenClipMode::ClipFinalSize,
            signal,
        );
    }

    fn do_tween_exit(&mut self, callback: Callable) {
        let window_rect_state: RectState = RectState {
            start: self.base().get_rect(),
            end: Rect2 {
                position: self.base().get_position() + (self.tween_enter_anchor * self.base().get_size()),
                size: Vector2::ZERO,
            },
        };

        // TODO: Direct declaration
        let tween_offset_mode: TweenOffsetMode;
        if self.do_tween_offset_exit { tween_offset_mode = TweenOffsetMode::Before }
        else { tween_offset_mode = TweenOffsetMode::None }

        let window_exit_info: Gd<TweenInfo> = self.tween_window_exit_info.clone();
        let offset_exit_info: Gd<TweenInfo> = self.tween_offset_exit_info.clone();

        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows
        let signal: AnimWindowSignal = this.signals().tween_exited().__typed;

        self.do_tween_change(
            window_rect_state.end,
            window_exit_info,
            offset_exit_info,
            tween_offset_mode,
            callback,
            TweenClipMode::ClipCurrentSize,
            signal,
        );
    }

    // endregion

    // region: Public Transform Functions

    // Animates in the window to the control's size, given by new_rect
    #[func]
    pub fn enter(&mut self, new_rect: Rect2, callback: Callable) {
        self.base_mut().set_position(new_rect.position);
        self.base_mut().set_size(new_rect.size);

        self.do_tween_enter(callback);
    }

    // TODO: Do not allow using these tween functions if there is already a tween
    // TODO: TODO: 	Queue? Don't allow? Option for both?

    // Change window position/size with animations
    #[func]
    pub fn set_rect(&mut self, new_rect: Rect2, callback: Callable) {
        let window_change_info: Gd<TweenInfo> = self.tween_window_change_info.clone();
        let offset_change_info: Gd<TweenInfo> = self.tween_offset_change_info.clone();

        let this: Gd<FilmWindow> = self.this.clone(); // Avoids borrowing issues since it self needs mutable borrows
        let signal: AnimWindowSignal = this.signals().tween_changed().__typed;


        self.do_tween_change(
            new_rect,
            window_change_info,
            offset_change_info,
            TweenOffsetMode::Both,
            callback,
            TweenClipMode::Stretch,
            signal
        );
    }

    // Change window position/size with animations, using a relative value
    #[func]
    pub fn set_rect_relative(&mut self, relative_rect: Rect2, callback: Callable) {
        let mut new_rect: Rect2 = self.base().get_rect();
        new_rect.position += relative_rect.position;
        new_rect.size += relative_rect.size;

        self.set_rect(new_rect, callback);
    }

    #[func]
    pub fn set_rect_pos(&mut self, new_pos: Vector2, callback: Callable) {
        let mut new_rect: Rect2 = self.base().get_rect();
        new_rect.position = new_pos;

        self.set_rect(new_rect, callback);
    }

    #[func]
    pub fn set_rect_size(&mut self, new_size: Vector2, callback: Callable) {
        let mut new_rect: Rect2 = self.base().get_rect();
        new_rect.size = new_size;

        self.set_rect(new_rect, callback);
    }

    // Run close animation while keeping the window in the scene tree
    #[func]
    pub fn minimize(&mut self) {
        let callback: Callable = self.base().callable("set_visible").bind(&[false.to_variant()]);

        self.do_tween_exit(callback);
    }

    // Shrink window and close
    #[func]
    pub fn close(&mut self) {
        let callback: Callable = self.base().callable("queue_free");

        self.do_tween_exit(callback);
    }

    // endregion
}