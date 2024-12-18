DELETE FROM public."user"
WHERE
    username LIKE 'usr%';

REFRESH MATERIALIZED VIEW public.top_this_week;    