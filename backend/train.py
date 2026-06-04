import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping, ReduceLROnPlateau
import json

# ── Paths ──────────────────────────────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
DATASET    = os.path.join(BASE_DIR, "dataset", "Freshwater Fish Disease Aquaculture in south asia")
TRAIN_DIR  = os.path.join(DATASET, "Train")
TEST_DIR   = os.path.join(DATASET, "Test")
MODEL_DIR  = os.path.join(BASE_DIR, "model")
MODEL_PATH = os.path.join(MODEL_DIR, "fish_disease_model.h5")
LABELS_PATH = os.path.join(MODEL_DIR, "class_labels.json")

# ── Config ─────────────────────────────────────────────────────────────────────
IMG_SIZE   = 224
BATCH_SIZE = 32
EPOCHS     = 30
NUM_CLASSES = 7

# ── Data augmentation ──────────────────────────────────────────────────────────
train_datagen = ImageDataGenerator(
    rescale=1.0 / 255,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode="nearest",
    validation_split=0.1,
)

test_datagen = ImageDataGenerator(rescale=1.0 / 255)

train_gen = train_datagen.flow_from_directory(
    TRAIN_DIR,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="training",
    shuffle=True,
)

val_gen = train_datagen.flow_from_directory(
    TRAIN_DIR,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="validation",
    shuffle=False,
)

test_gen = test_datagen.flow_from_directory(
    TEST_DIR,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    shuffle=False,
)

# Save class label mapping for the API to use
class_labels = {v: k for k, v in train_gen.class_indices.items()}
with open(LABELS_PATH, "w") as f:
    json.dump(class_labels, f, indent=2)
print(f"Classes: {train_gen.class_indices}")

# ── Model ──────────────────────────────────────────────────────────────────────
base_model = MobileNetV2(
    weights="imagenet",
    include_top=False,
    input_shape=(IMG_SIZE, IMG_SIZE, 3),
)
base_model.trainable = False  # freeze base for initial training

x = GlobalAveragePooling2D()(base_model.output)
x = Dense(256, activation="relu")(x)
x = Dropout(0.4)(x)
x = Dense(128, activation="relu")(x)
x = Dropout(0.3)(x)
output = Dense(NUM_CLASSES, activation="softmax")(x)

model = Model(base_model.input, output)

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

model.summary()

# ── Callbacks ──────────────────────────────────────────────────────────────────
callbacks = [
    ModelCheckpoint(
        MODEL_PATH,
        monitor="val_accuracy",
        save_best_only=True,
        verbose=1,
    ),
    EarlyStopping(
        monitor="val_accuracy",
        patience=7,
        restore_best_weights=True,
        verbose=1,
    ),
    ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.5,
        patience=3,
        min_lr=1e-6,
        verbose=1,
    ),
]

# ── Phase 1: Train top layers only ─────────────────────────────────────────────
print("\n=== Phase 1: Training top layers ===")
history = model.fit(
    train_gen,
    epochs=EPOCHS,
    validation_data=val_gen,
    callbacks=callbacks,
)

# ── Phase 2: Fine-tune last 30 layers of base model ───────────────────────────
print("\n=== Phase 2: Fine-tuning base model ===")
base_model.trainable = True
for layer in base_model.layers[:-30]:
    layer.trainable = False

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

history_fine = model.fit(
    train_gen,
    epochs=20,
    validation_data=val_gen,
    callbacks=callbacks,
)

# ── Evaluate on test set ───────────────────────────────────────────────────────
print("\n=== Test Set Evaluation ===")
loss, accuracy = model.evaluate(test_gen)
print(f"Test Accuracy: {accuracy * 100:.2f}%")
print(f"Test Loss:     {loss:.4f}")
print(f"\nModel saved to: {MODEL_PATH}")
print(f"Labels saved to: {LABELS_PATH}")
