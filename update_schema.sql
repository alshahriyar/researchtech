-- Add research_interest column to teachers table
ALTER TABLE teachers 
ADD COLUMN IF NOT EXISTS research_interest TEXT DEFAULT 'General Computer Science';

-- Update existing rows (if any)
UPDATE teachers 
SET research_interest = 'Machine Learning & AI' 
WHERE research_interest = 'General Computer Science';
