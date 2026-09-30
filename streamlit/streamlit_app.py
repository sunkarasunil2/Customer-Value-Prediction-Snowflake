import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(
    page_title="Customer Value Prediction",
    page_icon="📊",
    layout="wide"
)

session = get_active_session()

st.title("Customer Value Prediction")
st.write("Snowflake ML Binary Classification Application")

st.divider()

summary = session.sql("""
SELECT
    COUNT(*) AS TOTAL_PREDICTIONS,
    COUNT_IF(PREDICTED_VALUE IS NULL) AS NULL_PREDICTIONS,
    COUNT_IF(ACTUAL_VALUE = PREDICTED_VALUE) AS CORRECT_PREDICTIONS,
    ROUND(
        100.0 * COUNT_IF(ACTUAL_VALUE = PREDICTED_VALUE) / COUNT(*),
        2
    ) AS ACCURACY_PERCENT
FROM CUSTOMER_CHURN_DB.ML_SCHEMA.CUSTOMER_PREDICTIONS
""").to_pandas()

col1, col2, col3, col4 = st.columns(4)

col1.metric(
    "Total Predictions",
    int(summary.iloc[0]["TOTAL_PREDICTIONS"])
)

col2.metric(
    "Null Predictions",
    int(summary.iloc[0]["NULL_PREDICTIONS"])
)

col3.metric(
    "Correct Predictions",
    int(summary.iloc[0]["CORRECT_PREDICTIONS"])
)

col4.metric(
    "Accuracy",
    f'{summary.iloc[0]["ACCURACY_PERCENT"]}%'
)

st.divider()

st.subheader("Customer Predictions")

predictions = session.sql("""
SELECT
    CUSTOMER_ID,
    ACTUAL_VALUE,
    PREDICTED_VALUE,
    HIGH_VALUE_PROBABILITY
FROM CUSTOMER_CHURN_DB.ML_SCHEMA.CUSTOMER_PREDICTIONS
ORDER BY CUSTOMER_ID
LIMIT 100
""").to_pandas()

st.dataframe(
    predictions,
    use_container_width=True
)

st.divider()

st.subheader("Customer Prediction Lookup")

customer_id = st.number_input(
    "Enter Customer ID",
    min_value=1,
    step=1
)

if st.button("Predict Customer"):

    result = session.sql(f"""
    SELECT
        CUSTOMER_ID,
        ACTUAL_VALUE,
        PREDICTED_VALUE,
        HIGH_VALUE_PROBABILITY
    FROM CUSTOMER_CHURN_DB.ML_SCHEMA.CUSTOMER_PREDICTIONS
    WHERE CUSTOMER_ID = {customer_id}
    """).to_pandas()

    if result.empty:
        st.warning("Customer ID not found.")
    else:
        st.success("Customer found.")

        st.dataframe(
            result,
            use_container_width=True
        )

        predicted_value = int(result.iloc[0]["PREDICTED_VALUE"])

        if predicted_value == 1:
            st.success("Prediction: HIGH VALUE CUSTOMER")
        else:
            st.info("Prediction: NOT HIGH VALUE CUSTOMER")
