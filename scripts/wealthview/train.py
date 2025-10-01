import tensorflow as tf
from scripts.shared.logging import get_tensorboard_callback
import os

os.makedirs("outputs", exist_ok=True)
# Load and preprocess Fashion MNIST data
(x_train, y_train), (x_test, y_test) = tf.keras.datasets.fashion_mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

# Define model
model = tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(10)
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# TensorBoard logging
tensorboard_cb = get_tensorboard_callback("wealthview")

# Train and evaluate
model.fit(x_train, y_train, epochs=5,
          validation_data=(x_test, y_test),
          callbacks=[tensorboard_cb])

model.evaluate(x_test, y_test)
model.save("outputs/mnist_model.keras")  # Recommended native format
#model.save("outputs/wealthview_model")
