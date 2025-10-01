import tensorflow as tf
import datetime

def get_tensorboard_callback(name="run"):
    log_dir = f"logs/{name}/" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    return tf.keras.callbacks.TensorBoard(
        log_dir=log_dir,
        histogram_freq=1,
        write_graph=True,
        write_images=True
    )
