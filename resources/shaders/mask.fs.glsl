/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

struct RectangleVertex {
    vec4 position;
    vec4 color;
    vec4 st;
};

struct Rectangle {
    RectangleVertex vertices[4];
    vec4 radius;
    vec4 refPoint;
};

layout(std140) uniform RectangleBlock {
    Rectangle rectangles[256];
    vec4 rect_count;
};

struct Circle {
    vec4 center_outer_inner_radius;
    vec4 color;
};

layout(std140) uniform CircleBlock {
    Circle circles[256];
    vec4 circle_count;
};

void FetchVertex(int row, out vec4 pos, out vec4 color, out vec2 uv) {
    float s_pos = 0.0 / 16.0;
    float s_color = 4.0 / 16.0;
    float s_uv = 8.0 / 16.0;

    float t = float(row) / 256.0;

    pos = Texture(sDiffuse, vec2(s_pos, t));
    color = Texture(sDiffuse, vec2(s_color, t));
    uv = Texture(sDiffuse, vec2(s_uv, t)).xy;
}

void FetchRect(int rect_index,
               out vec4 p0, out vec4 c0, out vec2 st0,
               out vec4 p1, out vec4 c1, out vec2 st1,
               out vec4 p2, out vec4 c2, out vec2 st2,
               out vec4 p3, out vec4 c3, out vec2 st3,
               out vec4 radius,
               out vec2 refPoint) {
#if 1
    p0 = rectangles[rect_index].vertices[0].position;
    c0 = rectangles[rect_index].vertices[0].color;
    st0 = rectangles[rect_index].vertices[0].st.xy;

    p1 = rectangles[rect_index].vertices[1].position;
    c1 = rectangles[rect_index].vertices[1].color;
    st1 = rectangles[rect_index].vertices[1].st.xy;

    p2 = rectangles[rect_index].vertices[2].position;
    c2 = rectangles[rect_index].vertices[2].color;
    st2 = rectangles[rect_index].vertices[2].st.xy;

    p3 = rectangles[rect_index].vertices[3].position;
    c3 = rectangles[rect_index].vertices[3].color;
    st3 = rectangles[rect_index].vertices[3].st.xy;

    radius = rectangles[rect_index].radius;
    refPoint = rectangles[rect_index].refPoint.xy;
#else
    int row = rect_index * 4;
    FetchVertex(row + 0, p0, c0, st0);
    FetchVertex(row + 1, p1, c1, st1);
    FetchVertex(row + 2, p2, c2, st2);
    FetchVertex(row + 3, p3, c3, st3);
#endif
}

void FetchCircle(int circle_index,
                 out vec2 center,
                 out float outer_radius,
                 out float inner_radius,
                 out vec4 color)
{
    vec4 data = circles[circle_index].center_outer_inner_radius;
    center = data.xy;
    outer_radius = data.z;
    inner_radius = data.w;
    color = circles[circle_index].color;
}

float ScalarTriple(vec3 u, vec3 v, vec3 w)
{
    return dot(cross(u, v), w);
}

bool IntersectLineQuad(vec3 p,
                       vec3 q,
                       vec4 a,
                       vec4 b,
                       vec4 c,
                       vec4 d,
                       vec2 st0,
                       vec2 st1,
                       vec2 st2,
                       vec2 st3,
                       out vec3 r,
                       out vec2 st)
{
    vec3 sa = a.xyz / a.w;
    vec3 sb = b.xyz / b.w;
    vec3 sc = c.xyz / c.w;
    vec3 sd = d.xyz / d.w;

    vec3 pq = q - p;
    vec3 pa = sa - p;
    vec3 pb = sb - p;
    vec3 pc = sc - p;

/*
w' = ( 1 / v1.w ) * b1 + ( 1 / v2.w ) * b2 + ( 1 / v3.w ) * b3
u' = ( v1.u / v1.w ) * b1 + ( v2.u / v2.w ) * b2 + ( v3.u / v3.w ) * b3
v' = ...
perspCorrU = u' / w'
perspCorrV = v' / w'
*/

    // Determine which triangle to test against by testing against diagonal
    vec3 m = cross(pc, pq);
    float v = dot(pa, m);

    // ScalarTriple(pq, pa, pc);
    if (v >= 0.0) {
        // Test intersection against triangle abc
        float u = -dot(pb, m);
        // ScalarTriple(pq, pc, pb);
        if (u < 0.0) return false;
        float w = ScalarTriple(pq, pb, pa);
        if (w < 0.0) return false;
        // Compute r, r = u*a + v*b + w*c, from barycentric coordinates (u,
        float denom = 1.0 / (u + v + w);
        u *= denom;
        v *= denom;
        w *= denom;
        // w = 1.0f - u - v;
        r = u*sa + v*sb + w*sc;

        float nw = u*(1.0 / a.w) + v*(1.0 / b.w) + w*(1.0 / c.w);
        vec2 new_st = u*st0/a.w + v*st1/b.w + w*st2/c.w;
        st = new_st / nw;
        //st = u*st0 + v*st1 + w*st2;
    } else {
        // Test intersection against triangle dac
        vec3 pd = sd - p;
        float u = dot(pd, m);
        // ScalarTriple(pq, pd, pc);
        if (u < 0.0) return false;
        float w = ScalarTriple(pq, pa, pd);
        if (w < 0.0) return false;
        v = -v;
        // Compute r, r = u*a + v*d + w*c, from barycentric coordinates (u,
        float denom = 1.0 / (u + v + w);
        u *= denom;
        v *= denom;
        w *= denom;
        // w = 1.0f - u - v;
        r = u*sa + v*sd + w*sc;

        float nw = u*(1.0 / a.w) + v*(1.0 / d.w) + w*(1.0 / c.w);
        vec2 new_st = u*st0/a.w + v*st3/d.w + w*st2/c.w;
        st = new_st / nw;
        //st = u*st0 + v*st3 + w*st2;
    }
    return true;
}

bool PointInRect(vec2 p, vec2 p0, vec2 p1)
{
    vec2 s = step(p0, p) - step(p1, p);
    return s.x * s.y != 0.0;
}

vec2 Bilerp2(vec2 tl, vec2 tr, vec2 br, vec2 bl, vec2 st) {
    return mix(mix(tl, bl, st.y), mix(tr, br, st.y), st.x);
}

vec4 Bilerp4(vec4 tl, vec4 tr, vec4 br, vec4 bl, vec2 st) {
    return mix(mix(tl, bl, st.y), mix(tr, br, st.y), st.x);
}

#define DO_CIRCLES
//#define DO_RECTS

void main(void)
{
	int count = 0;

	vec3 final_color = vec3(0.4, 0.4, 0.4);

#ifdef DO_CIRCLES
    for (int x=0 ; x < int(circle_count.x) ; ++x) {
        vec2 center;
        vec4 color;
        float outer_radius, inner_radius;

        FetchCircle(x,
                    center,
                    outer_radius,
                    inner_radius,
                    color);

        float d = distance(vPosition.xy, center);

        if (d > inner_radius && d < outer_radius) {
            final_color = color.rgb * color.a + final_color * (1.0 - color.a);
        }
    }
#endif

#ifdef DO_RECTS
    vec3 p = vec3(vPosition.xy, -100.0);
    vec3 q = vec3(vPosition.xy,  100.0);

	for (int x=0 ; x < int(rect_count.x) ; ++x) {
		vec4 p0, c0, p1, c1, p2, c2, p3, c3, radius;
        vec2 st0, st1, st2, st3, refPoint;

		FetchRect(x,
                  p0, c0, st0,
                  p1, c1, st1,
                  p2, c2, st2,
                  p3, c3, st3,
                  radius,
                  refPoint);

/*
        vec3 r;
        vec2 st;

        if (IntersectLineQuad(p, q, p0, p1, p2, p3, st0, st1, st2, st3, r, st)) {
            vec2 test_st = st;// / r.z;// Bilerp2(sp0.xy, sp3.xy, sp1.xy, sp2.xy, r.xy);

            // check radius/clip
            bool isValid = true;

            if (radius.x > 0.0 && radius.y > 0.0) {
                //vec2 refPoint = p1.xy;// + vec2(radius.x, radius.y);
                vec2 delta = r.xy - refPoint;
                float dist = sqrt(delta.x*delta.x + delta.y*delta.y);
                if (dist > radius.x || dist < radius.z) {
                    isValid = false;
                }
            }

            if (isValid) {
                vec4 tc = vec4(1,1,1,1);// Texture(sMask, test_st);

                float frag_alpha = c0.a * tc.a;
                vec3 frag_color = c0.rgb * tc.rgb;

                final_color = frag_color * frag_alpha + final_color * (1.0 - frag_alpha);
            }
        }
*/

		if (PointInRect(vPosition, p0.xy, p2.xy)) {
	        //vec2 local_st = (vPosition.xy - p0.xy) / (p2.xy - p0.xy);
		    //vec2 real_st = st0.xy + local_st * (st2.xy - st0.xy);

            bool isValid = true;

            if (radius.x > 0.0 && radius.y > 0.0) {
                vec2 delta = vPosition.xy - refPoint;
                float dist = sqrt(delta.x*delta.x + delta.y*delta.y);
                if (dist > radius.x || dist < radius.z) {
                    isValid = false;
                }
            }

            if (isValid) {
                vec4 tc = vec4(1,1,1,1);// Texture(sMask, test_st);

                vec4 frag = c0 * tc;
                //float frag_alpha = c0.a * tc.a;
                //vec3 frag_color = c0.rgb * tc.rgb;

                final_color = frag.rgb * frag.a + final_color * (1.0 - frag.a);
            }
		}

	}
#endif

    SetFragColor(vec4(final_color, 1));
}
