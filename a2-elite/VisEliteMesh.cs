/*
 * Copyright 2020 faddenSoft
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
using System;
using System.Collections.ObjectModel;

using PluginCommon;

namespace Elite {
    /// <summary>
    /// Visualizer for Elite hull meshes.  This was developed for the Apple II version, but
    /// the ship data seems to be in the same format for at least BBC and C64.
    /// </summary>
    public class EliteMesh : MarshalByRefObject, IPlugin, IPlugin_Visualizer_v2 {
        // IPlugin
        public string Identifier {
            get { return "Elite Mesh Visualizer"; }
        }
        private IApplication mAppRef;
        private byte[] mFileData;

        // Visualization identifiers; DO NOT change or projects that use them will break.
        private const string VIS_GEN_ELITE_MESH = "elite-mesh";

        private const string P_OFFSET = "offset";
        private const string P_LOD_DISTANCE = "lodDistance";
        private const string P_DO_FIX_NORMALS = "doFixNormals";
        private const string P_DO_CULL_VERTICES = "doCullVertices";

        private const int DEFAULT_LOD_DIST = 0;  // very close

        // If this is true, we rotate the object about the Y axis by inverting X/Z coords.
        // This faces the ship to the front by default, which makes the default (0,0,0)
        // rotation slightly nicer to look at, but is annoying if you're trying to examine
        // the coordinates.
        private bool TURN_TO_FRONT = false;

        // Visualization descriptors.
        private VisDescr[] mDescriptors = new VisDescr[] {
            new VisDescr(VIS_GEN_ELITE_MESH, "Elite Hull Mesh", VisDescr.VisType.Wireframe,
                new VisParamDescr[] {
                    new VisParamDescr("File offset (hex)",
                        P_OFFSET, typeof(int), 0, 0x00ffffff, VisParamDescr.SpecialMode.Offset, 0),

                    new VisParamDescr("LOD distance",
                        P_LOD_DISTANCE, typeof(int), 0, 31, 0, DEFAULT_LOD_DIST),

                    // These are interpreted by the main app.
                    //VisWireframe.Param_IsPerspective("Perspective projection", true),
                    VisWireframe.Param_IsBfcEnabled("Backface culling", true),

                    new VisParamDescr("Fix normals",
                        P_DO_FIX_NORMALS, typeof(bool), 0, 0, 0, true),
                    new VisParamDescr("Cull vertices",
                        P_DO_CULL_VERTICES, typeof(bool), 0, 0, 0, false),
                }),
        };


        // IPlugin
        public void Prepare(IApplication appRef, byte[] fileData, AddressTranslate addrTrans) {
            mAppRef = appRef;
            mFileData = fileData;
        }

        // IPlugin
        public void Unprepare() {
            mAppRef = null;
            mFileData = null;
        }

        // IPlugin_Visualizer
        public VisDescr[] GetVisGenDescrs() {
            if (mFileData == null) {
                return null;
            }
            return mDescriptors;
        }

        // IPlugin_Visualizer
        public IVisualization2d Generate2d(VisDescr descr,
                ReadOnlyDictionary<string, object> parms) {
            mAppRef.ReportError("2d not supported");
            return null;
        }

        // IPlugin_Visualizer_v2
        public IVisualizationWireframe GenerateWireframe(VisDescr descr,
                ReadOnlyDictionary<string, object> parms) {
            switch (descr.Ident) {
                case VIS_GEN_ELITE_MESH:
                    return GenerateWireframe(parms);
                default:
                    mAppRef.ReportError("Unknown ident " + descr.Ident);
                    return null;
            }
        }

        private IVisualizationWireframe GenerateWireframe(ReadOnlyDictionary<string, object> parms) {
            int offset = Util.GetFromObjDict(parms, P_OFFSET, 0);
            int lodDist = Util.GetFromObjDict(parms, P_LOD_DISTANCE, DEFAULT_LOD_DIST);
            bool doFixNormals = Util.GetFromObjDict(parms, P_DO_FIX_NORMALS, true);
            bool doCullVertices = Util.GetFromObjDict(parms, P_DO_CULL_VERTICES, false);

            if (offset < 0 || offset >= mFileData.Length) {
                // should be caught by editor
                mAppRef.ReportError("Invalid parameter");
                return null;
            }

            VisWireframe vw = new VisWireframe();
            try {
                int edgeOffset = offset + (short)(mFileData[offset + 0x03] |
                    (mFileData[offset + 0x10] << 8));
                int faceOffset = offset + (short)(mFileData[offset + 0x04] |
                    (mFileData[offset + 0x11] << 8));
                int vertexCount = mFileData[offset + 0x08] / 6;
                int edgeCount = mFileData[offset + 0x09];
                int faceCount = mFileData[offset + 0x0c] / 4;

                //mAppRef.DebugLog("MESH vc=" + vertexCount + " ec=" + edgeCount + " fc=" + faceCount +
                //    " eoff=" + edgeOffset + " foff=" + faceOffset);

                int vertexOffset = offset + 0x14;
                for (int i = 0; i < vertexCount; i++) {
                    int xc = mFileData[vertexOffset++];
                    int yc = mFileData[vertexOffset++];
                    int zc = mFileData[vertexOffset++];
                    byte flags = mFileData[vertexOffset++];
                    byte faces0 = mFileData[vertexOffset++];
                    byte faces1 = mFileData[vertexOffset++];

                    if ((flags & 0x80) != 0) {
                        xc = -xc;
                    }
                    if ((flags & 0x40) != 0) {
                        yc = -yc;
                    }
                    if ((flags & 0x20) != 0) {
                        zc = -zc;
                    }
                    int visThresh = flags & 0x1f;
                    if (TURN_TO_FRONT) {
                        xc = -xc;
                        zc = -zc;
                    }

                    int vindex = vw.AddVertex(xc, yc, zc);
                    if (doCullVertices) {
                        AddVertexFace(vw, vindex, faces0 & 0x0f, faceCount);
                        AddVertexFace(vw, vindex, faces0 >> 4, faceCount);
                        AddVertexFace(vw, vindex, faces1 & 0x0f, faceCount);
                        AddVertexFace(vw, vindex, faces1 >> 4, faceCount);
                    }

                    if (visThresh < lodDist) {
                        vw.AddVertexExclusion(vindex);
                    }

                    //mAppRef.DebugLog("v" + i + " " + xc + "," + yc + "," + zc +
                    //    " :: " + (faces0 & 0x0f) + "," + (faces0 >> 4) + "," +
                    //    (faces1 & 0x0f) + "," + (faces1 >> 4));
                }

                for (int i = 0; i < edgeCount; i++) {
                    byte flags = mFileData[edgeOffset++];
                    byte faces = mFileData[edgeOffset++];
                    byte v0 = mFileData[edgeOffset++];
                    byte v1 = mFileData[edgeOffset++];
                    int visThresh = flags & 0x1f;

                    int eindex = vw.AddEdge(v0 / 4, v1 / 4);
                    AddEdgeFace(vw, eindex, faces & 0x0f, faceCount);
                    AddEdgeFace(vw, eindex, faces >> 4, faceCount);

                    if (visThresh < lodDist) {
                        vw.AddEdgeExclusion(eindex);
                    }

                    //mAppRef.DebugLog("E" + i + " " + (v0 / 4) + "," + (v1 / 4) +
                    //    " :: " + (faces & 0x0f) + "," + (faces >> 4));
                }

                for (int i = 0; i < faceCount; i++) {
                    byte flags = mFileData[faceOffset++];
                    int xc = mFileData[faceOffset++];
                    int yc = mFileData[faceOffset++];
                    int zc = mFileData[faceOffset++];

                    if ((flags & 0x80) != 0) {
                        xc = -xc;
                    }
                    if ((flags & 0x40) != 0) {
                        yc = -yc;
                    }
                    if ((flags & 0x20) != 0) {
                        zc = -zc;
                    }
                    if (TURN_TO_FRONT) {
                        xc = -xc;
                        zc = -zc;
                    }

                    //int visThresh = flags & 0x1f;
                    // We don't handle the face visibility threshold, which is only used
                    // for the "plate / alloys" hull to disable BFC.

                    if (new Vector3(xc, yc, zc).Magnitude() == 0) {
                        // We have two choices:
                        // (1) Add a placeholder (say, [0,0,1]).  Causes the renderer to
                        //     get confused if there's no vertex for the face.
                        // (2) Drop it, as it's clearly not used.  Potentially problematic if
                        //     there are other faces that *are* used, because we throw the
                        //     indices off by one.
                        // So far this only seems to be a thing for "plate / alloys" which
                        // doesn't do BFC, so I'm taking approach #2.
                    } else {
                        vw.AddFaceNormal(xc, yc, zc);
                    }

                    //mAppRef.DebugLog("F" + i + " " + xc + "," + yc + "," + zc);
                }
            } catch (IndexOutOfRangeException) {
                // assume it was our file data access that caused the failure
                mAppRef.ReportError("Ran off end of file");
                return null;
            }

            string msg;
            if (!vw.Validate(out msg)) {
                mAppRef.ReportError("Data error: " + msg);
                return null;
            }

            if (doFixNormals) {
                FixNormals(vw, offset);
            }

            return vw;
        }

        /// <summary>
        /// Adds a face to the vertex's face list if the face index is in range.  (Some
        /// shapes, such as the Cobra Mk III, use $ff for their vertex face values even
        /// though fewer than 16 faces are defined.)
        /// </summary>
        private void AddVertexFace(VisWireframe vw, int vindex, int face, int faceCount) {
            if (face < faceCount) {
                vw.AddVertexFace(vindex, face);
            }
        }

        /// <summary>
        /// Adds a face to the edge's face list if the face index is in range.  (Some
        /// shapes, such as "plate / alloys", use $ff for their edge face value even
        /// though fewer than 16 faces are defined.)
        /// </summary>
        private void AddEdgeFace(VisWireframe vw, int eindex, int face, int faceCount) {
            if (face < faceCount) {
                vw.AddEdgeFace(eindex, face);
            }
        }

        /// <summary>
        /// Attempts to fix the surface normals.  Call this after the shape has been
        /// loaded and the data validated.
        /// </summary>
        /// <param name="vw">Wireframe data.</param>
        /// <param name="offset">Initial shape offset.</param>
        private void FixNormals(VisWireframe vw, int offset) {
            const int minVisThresh = 0x9;

            int edgeOffset = offset + (short)(mFileData[offset + 0x03] |
                (mFileData[offset + 0x10] << 8));
            int faceOffset = offset + (short)(mFileData[offset + 0x04] |
                (mFileData[offset + 0x11] << 8));

            float[] verticesX = vw.GetVerticesX();
            float[] verticesY = vw.GetVerticesY();
            float[] verticesZ = vw.GetVerticesZ();
            float[] normalsX = vw.GetNormalsX();
            float[] normalsY = vw.GetNormalsY();
            float[] normalsZ = vw.GetNormalsZ();
            IntPair[] edges = vw.GetEdges();
            IntPair[] edgeFaces = vw.GetEdgeFaces();

            for (int face = 0; face < normalsX.Length; face++) {
                // Find the first edge that references this face.  We ignore anything whose
                // visibility threshold is too low.
                int edge = -1;
                int ef;
                for (ef = 0; ef < edgeFaces.Length; ef++) {
                    // pull the flags out of the edge data to get the visibility threshold
                    byte flags = mFileData[edgeOffset + edgeFaces[ef].Val0 * 4];
                    if (flags > 0x1f) {
                        mAppRef.DebugLog("BAD FLAG " + flags.ToString("x2"));
                    }
                    if (flags < minVisThresh) {
                        continue;
                    }
                    if (edgeFaces[ef].Val1 == face) {
                        edge = edgeFaces[ef].Val0;
                        break;
                    }
                }
                if (edge < 0) {
                    mAppRef.DebugLog("Unable to find first edge for face " + face);
                    continue;
                }

                // Extract the two vertices.
                int v0 = edges[edge].Val0;
                int v1 = edges[edge].Val1;

                // Find another edge for this face that has a common vertex.
                edge = -1;
                for (++ef ; ef < edgeFaces.Length; ef++) {
                    byte flags = mFileData[edgeOffset + edgeFaces[ef].Val0 * 4];
                    if (flags > 0x1f) {
                        mAppRef.DebugLog("BAD FLAG " + flags.ToString("x2"));
                    }
                    if (flags < minVisThresh) {
                        continue;
                    }
                    if (edgeFaces[ef].Val1 == face) {
                        int chkEdge = edgeFaces[ef].Val0;
                        if (edges[chkEdge].Val0 == v0 || edges[chkEdge].Val0 == v1 ||
                                edges[chkEdge].Val1 == v0 || edges[chkEdge].Val1 == v1) {
                            edge = chkEdge;
                            break;
                        }
                    }
                }
                if (edge < 0) {
                    mAppRef.DebugLog("Unable to find second edge for face " + face);
                    continue;
                }

                // Arrange the vertices so the edges are v0-v1 and v1-v2.  If the edges have
                // v0 in common we shuffle things around.
                int v2;
                if (edges[edge].Val0 == v0) {
                    v2 = v1;
                    v1 = v0;
                    v0 = edges[edge].Val1;
                } else if (edges[edge].Val1 == v0) {
                    v2 = v1;
                    v1 = v0;
                    v0 = edges[edge].Val0;
                } else if (edges[edge].Val0 == v1) {
                    v2 = edges[edge].Val1;
                } else if (edges[edge].Val1 == v1) {
                    v2 = edges[edge].Val0;
                } else {
                    mAppRef.DebugLog("BUG!");
                    continue;
                }

                //mAppRef.DebugLog("Face " + face + ": using vertices " + v0 + "," + v1 + "," + v2);

                // Create vectors for the edges.
                Vector3 vec0 = new Vector3(verticesX[v0], verticesY[v0], verticesZ[v0]);
                Vector3 vec1 = new Vector3(verticesX[v1], verticesY[v1], verticesZ[v1]);
                Vector3 vec2 = new Vector3(verticesX[v2], verticesY[v2], verticesZ[v2]);
                Vector3 evec0 = Vector3.Subtract(vec0, vec1);
                Vector3 evec1 = Vector3.Subtract(vec1, vec2);

                // Compute the cross product.
                Vector3 cross = Vector3.Cross(evec0, evec1);
                Vector3 negCross = cross.Multiply(-1);

                //mAppRef.DebugLog("  evec0=" + evec0 + " evec1=" + evec1 + " cross=" + cross);

                // Check to see if we got the sign backward by adding the new vector to
                // one of the vertices.  If it moves us farther from the center of the
                // object, it's facing outward, and we're good.
                if (Vector3.Add(vec0, cross).Magnitude() <
                        Vector3.Add(vec0, negCross).Magnitude()) {
                    // flip it
                    cross = negCross;
                }

                // Replace the entry.
                Vector3 orig =
                    new Vector3(normalsX[face], normalsY[face], normalsZ[face]).Normalize();
                Vector3 subst = cross.Normalize();
                vw.ReplaceFaceNormal(face, (float)subst.X, (float)subst.Y, (float)subst.Z);

                //double ang = Math.Acos(Vector3.Dot(orig, subst));
                //mAppRef.DebugLog("Face " + face.ToString("D2") + ": " + subst +
                //    " vs. orig " + orig +
                //    " (off by " + (ang * 180.0 / Math.PI).ToString("N2") + " deg)");
            }
        }
    }
}
