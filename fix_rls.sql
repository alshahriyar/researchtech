-- ============================================
-- Fix RLS Policies for Login
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Students can view their own profile" ON students;
DROP POLICY IF EXISTS "Students can update their own profile" ON students;
DROP POLICY IF EXISTS "Anyone can insert students during registration" ON students;

DROP POLICY IF EXISTS "Teachers can view their own profile" ON teachers;
DROP POLICY IF EXISTS "Anyone can view teachers for search" ON teachers;
DROP POLICY IF EXISTS "Teachers can update their own profile" ON teachers;
DROP POLICY IF EXISTS "Anyone can insert teachers during registration" ON teachers;

-- 2. RE-CREATE Students policies with broader select permissions for debugging
-- Allow authenticated users to view their own profile
CREATE POLICY "Students can view their own profile" ON students
  FOR SELECT USING (auth.uid() = auth_user_id);

-- Allow new users to insert their profile
CREATE POLICY "Enable insert for authenticated users only" ON students
  FOR INSERT WITH CHECK (auth.uid() = auth_user_id);
  
-- Allow users to update their own profile
CREATE POLICY "Students can update their own profile" ON students
  FOR UPDATE USING (auth.uid() = auth_user_id);

-- 3. RE-CREATE Teachers policies
CREATE POLICY "Teachers can view their own profile" ON teachers
  FOR SELECT USING (auth.uid() = auth_user_id);

CREATE POLICY "Anyone can view teachers for search" ON teachers
  FOR SELECT USING (true);

CREATE POLICY "Teachers can update their own profile" ON teachers
  FOR UPDATE USING (auth.uid() = auth_user_id);

CREATE POLICY "Enable insert for authenticated teachers" ON teachers
  FOR INSERT WITH CHECK (auth.uid() = auth_user_id);

-- 4. Grant permissions explicitly (just in case)
GRANT SELECT, INSERT, UPDATE, DELETE ON students TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON teachers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON proposals TO authenticated;

-- 5. Force specific simple policy for testing if above fails (Emergency fallback)
-- CREATE POLICY "Allow all select for authenticated" ON students FOR SELECT TO authenticated USING (true);
