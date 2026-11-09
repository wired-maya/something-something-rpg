#![allow(dead_code)] // Temp

use godot::prelude::*;

mod film_window;
mod anim_data_types;

struct FilmWindowLib;

#[gdextension]
unsafe impl ExtensionLibrary for FilmWindowLib {}