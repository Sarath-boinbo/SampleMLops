# src/data_preprocessing.py
import argparse
import pandas as pd
from sklearn.model_selection import train_test_split
from pathlib import Path

def preprocess_data(input_path: str, output_dir: str):
    """Loads, cleans, encodes, and splits the Telco churn data."""
    print(f"Reading data from {input_path}...")
    df = pd.read_csv(input_path)

    # --- Data Cleaning ---
    # The 'TotalCharges' column has empty strings for new customers.
    # Replace these with NaN, then convert the column to a numeric type.
    df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')
    # Fill the few resulting NaN values (e.g., with the median).
    df['TotalCharges'].fillna(df['TotalCharges'].median(), inplace=True)

    # --- Feature Engineering & Encoding ---
    # Convert binary 'Yes'/'No' columns to 1/0
    binary_cols = ['Partner', 'Dependents', 'PhoneService', 'PaperlessBilling', 'Churn']
    for col in binary_cols:
        df[col] = df[col].apply(lambda x: 1 if x == 'Yes' else 0)

    # One-Hot Encode multi-category features
    categorical_cols = df.select_dtypes(include=['object']).columns.drop('customerID').tolist()
    df = pd.get_dummies(df, columns=categorical_cols, drop_first=True)

    print("Data cleaned and encoded.")

    # --- Data Splitting ---
    # Split data into training (70%), validation (15%), and test (15%) sets.
    train_val_df, test_df = train_test_split(df, test_size=0.15, random_state=42, stratify=df['Churn'])
    train_df, val_df = train_test_split(train_val_df, test_size=(0.15/0.85), random_state=42, stratify=train_val_df['Churn'])

    print(f"Train set shape: {train_df.shape}")
    print(f"Validation set shape: {val_df.shape}")
    print(f"Test set shape: {test_df.shape}")

    # --- Save Processed Data ---
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True) # Ensure directory exists

    train_df.to_csv(output_path / "train.csv", index=False)
    val_df.to_csv(output_path / "val.csv", index=False)
    test_df.to_csv(output_path / "test.csv", index=False)

    print(f"Processed datasets saved to {output_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Data Preprocessing for Churn Prediction")
    parser.add_argument("--input-path", type=str, required=True, help="Path to the raw CSV data")
    parser.add_argument("--output-dir", type=str, required=True, help="Directory to save processed data")
    args = parser.parse_args()

    preprocess_data(args.input_path, args.output_dir)