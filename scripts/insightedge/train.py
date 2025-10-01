import tensorflow as tf
from scripts.shared.logging import get_tensorboard_callback

(x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(10)
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

tensorboard_cb = get_tensorboard_callback("insightedge")

model.fit(x_train, y_train, epochs=5,
          validation_data=(x_test, y_test),
          callbacks=[tensorboard_cb])

model.save("outputs/mnist_model")
