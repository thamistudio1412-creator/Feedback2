// ส่งค่า Supabase URL + anon/publishable key ให้หน้าเว็บ
// (anon key เป็นคีย์สาธารณะอยู่แล้ว ความปลอดภัยมาจาก RLS ใน supabase.sql)
// ส่วน GEMINI_API_KEY จะไม่ถูกส่งออกไปหน้าเว็บเด็ดขาด

export default async () => {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey) {
    return Response.json(
      { error: "ยังไม่ได้ตั้งค่า SUPABASE_URL หรือ SUPABASE_ANON_KEY ใน Netlify" },
      { status: 500 }
    );
  }

  return Response.json(
    { supabaseUrl, supabaseKey },
    { headers: { "Cache-Control": "public, max-age=300" } }
  );
};

export const config = { path: "/api/config" };
