import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = 'https://moykcachkwohnjlfuldk.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_-ikaN09b0_kIcqdXNpOkfQ_Sb3KYf4N';

export const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);
