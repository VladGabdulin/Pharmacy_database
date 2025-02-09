CREATE OR REPLACE FUNCTION calculate_top_medicines(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    medicine_id INT,
    total_quantity INT
) AS $$
DECLARE
    sale_cursor CURSOR FOR
        SELECT medicines FROM Sales_Fact
        WHERE sale_date BETWEEN start_date AND end_date;

    medicine_entry RECORD;
    medicine_totals JSONB := '{}';
    current_medicine_id INT;
    current_quantity INT;
BEGIN
    -- Открываем курсор для обработки записей
    OPEN sale_cursor;

    LOOP
        -- Извлекаем следующую запись
        FETCH sale_cursor INTO medicine_entry;

        -- Если больше данных нет, выходим из цикла
        EXIT WHEN NOT FOUND;

        -- Итерация по массиву medicines[][2]
        FOR i IN 1 .. array_length(medicine_entry.medicines, 1) LOOP
            current_medicine_id := medicine_entry.medicines[i][1]::INT;
            current_quantity := medicine_entry.medicines[i][2]::INT;

            -- Обновляем количество для текущего лекарства
            IF medicine_totals ? current_medicine_id::TEXT THEN
                medicine_totals := jsonb_set(
                    medicine_totals,
                    ARRAY[current_medicine_id::TEXT],
                    (medicine_totals->>current_medicine_id::TEXT)::INT + current_quantity
                );
            ELSE
                medicine_totals := jsonb_set(
                    medicine_totals,
                    ARRAY[current_medicine_id::TEXT],
                    to_jsonb(current_quantity)
                );
            END IF;
        END LOOP;
    END LOOP;

    -- Закрываем курсор
    CLOSE sale_cursor;

    -- Возвращаем топ-3 лекарства с максимальным количеством продаж
    RETURN QUERY
    SELECT key::INT AS medicine_id, value::INT AS total_quantity
    FROM jsonb_each_text(medicine_totals)
    ORDER BY value::INT DESC
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM calculate_top_medicines('2024-01-01', '2024-12-31');
