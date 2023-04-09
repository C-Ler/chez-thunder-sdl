;;; tc guardian.ss
;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
(define sdl-guardian (make-guardian))	;make-guardian见CSUG,用于内存管理,垃圾回收

(define (sdl-guard-pointer obj) 
  (sdl-free-garbage) 
  (sdl-guardian obj) 
  obj)

(define sdl-free-garbage-func (lambda () (if #f #f)))
(define (sdl-free-garbage-set-func f) (set! sdl-free-garbage-func f))
(define (sdl-free-garbage) (sdl-free-garbage-func))
