WITH PREDICTIONS AS
(
    SELECT
        HIGH_VALUE,
        CUSTOMER_VALUE_MODEL!PREDICT(
            INPUT_DATA => {*}
        ):class::INT AS PREDICTED_VALUE
    FROM CUSTOMER_TEST_FEATURES
)
SELECT
    COUNT(*) AS TOTAL_TEST_ROWS,
    SUM(
        CASE
            WHEN HIGH_VALUE = PREDICTED_VALUE
            THEN 1
            ELSE 0
        END
    ) AS CORRECT_PREDICTIONS,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN HIGH_VALUE = PREDICTED_VALUE
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS ACCURACY_PERCENT
FROM PREDICTIONS;


WITH PREDICTIONS AS
(
    SELECT
        HIGH_VALUE AS ACTUAL,
        CUSTOMER_VALUE_MODEL!PREDICT(
            INPUT_DATA => {*}
        ):class::INT AS PREDICTED
    FROM CUSTOMER_TEST_FEATURES
)
SELECT
    ACTUAL,
    PREDICTED,
    COUNT(*) AS COUNT
FROM PREDICTIONS
WHERE PREDICTED IS NOT NULL
GROUP BY ACTUAL, PREDICTED
ORDER BY ACTUAL, PREDICTED;


WITH PREDICTIONS AS
(
    SELECT
        HIGH_VALUE AS ACTUAL,
        CUSTOMER_VALUE_MODEL!PREDICT(
            INPUT_DATA => {*}
        ):class::INT AS PREDICTED
    FROM CUSTOMER_TEST_FEATURES
),
METRICS AS
(
    SELECT
        SUM(
            CASE
                WHEN ACTUAL = 0 AND PREDICTED = 0
                THEN 1
                ELSE 0
            END
        ) AS TN,
        SUM(
            CASE
                WHEN ACTUAL = 0 AND PREDICTED = 1
                THEN 1
                ELSE 0
            END
        ) AS FP,
        SUM(
            CASE
                WHEN ACTUAL = 1 AND PREDICTED = 0
                THEN 1
                ELSE 0
            END
        ) AS FN,
        SUM(
            CASE
                WHEN ACTUAL = 1 AND PREDICTED = 1
                THEN 1
                ELSE 0
            END
        ) AS TP
    FROM PREDICTIONS
)
SELECT
    TN,
    FP,
    FN,
    TP,
    ROUND(
        100.0 * TP / NULLIF(TP + FP, 0),
        2
    ) AS PRECISION_PERCENT,
    ROUND(
        100.0 * TP / NULLIF(TP + FN, 0),
        2
    ) AS RECALL_PERCENT,
    ROUND(
        100.0 * (2 * TP) / NULLIF(2 * TP + FP + FN, 0),
        2
    ) AS F1_SCORE_PERCENT
FROM METRICS;


SELECT
    COUNT(*) AS TOTAL_PREDICTIONS,
    COUNT_IF(
        PREDICTED_VALUE IS NULL
    ) AS NULL_PREDICTIONS,
    COUNT_IF(
        ACTUAL_VALUE = PREDICTED_VALUE
    ) AS CORRECT_PREDICTIONS
FROM CUSTOMER_PREDICTIONS;
