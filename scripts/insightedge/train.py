import argparse
import json
import os
import tensorflow as tf

# Default training config
default_config = {
    "epochs": 5,
    "batch_size": 32,
    "learning_rate": 0.001,
    "validation_split": 0.1,
    "model_path": "outputs/mnist_model.keras"
}

def load_config(path):
    config = default_config.copy()
    if path and os.path.exists(path):
        with open(path) as f:
            user_config = json.load(f)
        config.update(user_config)  # Only override specified keys
    return config

def run_training(config):
    import os
    import tensorflow as tf

    # Ensure output directory exists
    os.makedirs(os.path.dirname(config["model_path"]), exist_ok=True)

    # Load and preprocess MNIST data
    (x_train, y_train), _ = tf.keras.datasets.mnist.load_data()
    x_train = x_train / 255.0

    # Define model architecture
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(28, 28)),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(10, activation='softmax')
    ])

    # Compile model with config-driven hyperparameters
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=config["learning_rate"]),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )

    # Optional: TensorBoard logging
    log_dir = "logs"
    tensorboard_cb = tf.keras.callbacks.TensorBoard(log_dir=log_dir)

    # Train model
    model.fit(
        x_train, y_train,
        epochs=config["epochs"],
        batch_size=config["batch_size"],
        validation_split=config["validation_split"],
        callbacks=[tensorboard_cb]
    )

    # Save model
    model.save(config["model_path"])
    print(f"Model saved to {config['model_path']}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--training_config", type=str, help="Path to JSON config file")
    args = parser.parse_args()

    config = load_config(args.training_config)
    run_training(config)

if __name__ == "__main__":
    main()
