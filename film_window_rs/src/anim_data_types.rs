use godot::classes::Control;
use godot::prelude::*;
use godot::classes::{tween::{EaseType, TransitionType}};
use godot::signal::TypedSignal;

use crate::film_window::FilmWindow;

// TODO: Expose to GDScript, maybe make structs in general a thing in GDScript

// region: Types

pub type AnimComponentSignal<'f> = TypedSignal<'f, FilmWindow, (Gd<FilmWindow>, Gd<RectState>, Gd<TweenInfo>)>;
pub type AnimControlSignal<'f> = TypedSignal<'f, FilmWindow, (Gd<Control>, Gd<RectState>, Gd<TweenInfo>)>;
pub type AnimSignal<'f> = TypedSignal<'f, FilmWindow, (Gd<FilmWindow>, Gd<RectState>, Gd<RectState>, Gd<TweenInfo>)>;
pub type AnimWindowSignal<'f> = TypedSignal<'f, FilmWindow,
    (
        Gd<FilmWindow>,
        Gd<RectState>, // Window content container state
        Gd<RectState>, // Window shadow state
        Gd<TweenInfo>, // Window tween
        Gd<RectState>, // Offset content container state
        Gd<RectState>, // Offset shadow state
        Gd<TweenInfo>, // Offset tween info
        f64, // Delay
        f64, // Duration
    )
>;

// endregion

// region: Enums

#[derive(GodotConvert, Var, Export, Clone, PartialEq)]
#[godot(via = GString)]
pub enum TweenOffsetMode {
	Both,
	Before,
	After,
	None
}

#[derive(GodotConvert, Var, Export, Clone, PartialEq)]
#[godot(via = GString)]
pub enum TweenClipMode {
	Stretch,
	ClipCurrentSize,
	ClipFinalSize
}

#[derive(GodotConvert, Var, Export, Clone, PartialEq)]
#[godot(via = GString)]
pub enum TweenBufferMode {
	Buffer,
	Ignore
}

#[derive(GodotConvert, Var, Export, Clone, PartialEq)]
#[godot(via = GString)]
pub enum TweenOffsetMotion {
	Apart,
	Together
}

// endregion

// region: TweenInfo

#[derive(GodotClass, Clone, PartialEq)]
#[class(init)]
pub struct TweenInfo {
    #[init(val = TransitionType::SINE)] pub trans_type: TransitionType,
    #[init(val = EaseType::IN_OUT)] pub ease_type: EaseType,
    #[init(val = 0.0)] pub delay: f64,
    #[init(val = 0.5)] pub duration: f64,
}

#[godot_api]
impl TweenInfo {
    // TODO: Use different func name
    #[func] pub fn from(trans_type: TransitionType, ease_type: EaseType, delay: f64, duration: f64) -> Gd<Self> {
        Gd::from_object(
            Self {
                trans_type,
                ease_type,
                delay,
                duration
            }
        )
    }
}

// endregion

// region: RectState

#[derive(GodotClass, Default, Clone, PartialEq)]
#[class(no_init)]
pub struct RectState {
    pub start: Rect2,
    pub end: Rect2,
}

#[godot_api]
impl RectState {
    #[func] pub fn from(start: Rect2, end: Rect2) -> Gd<Self> { Gd::from_object(Self { start, end }) }

    // If you want to transform from origin, useful for offsets
    #[func] pub fn from_start(start: Rect2) -> Gd<Self> { Gd::from_object(Self { start, end: Default::default() }) }
    #[func] pub fn from_end(end: Rect2) -> Gd<Self> { Gd::from_object(Self { start: Default::default(), end }) }
}

// endregion