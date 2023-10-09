;;; -*- lexical-binding: t; -*-
(require 'json)

(unless (boundp 'native-comp-deferred-compilation-deny-list)
  (defvaralias 'native-comp-deferred-compilation-deny-list 'native-comp-jit-compilation-deny-list))

(defun nix-straight-get-used-packages (init-file output-file)
  (let ((nix-straight--packages nil))
    (advice-add 'straight-use-package
                :override (lambda (recipe &rest r)
                            (let ((pkg (if (listp recipe)
                                           (car recipe)
                                         recipe)))
                              (message "[nix-straight.el] Collecting package '%s' from recipe '%s'" pkg recipe)
                              (add-to-list 'nix-straight--packages pkg))))

    (load init-file nil nil t)
    (let ((json-pkgs (if (null nix-straight--packages)
               "[]"
             (json-encode nix-straight--packages))))
      (write-region json-pkgs nil output-file))

    nix-straight--packages))

(defun nix-straight-build-packages (init-file)
  (setq straight-default-files-directive '("*" (:exclude "*.elc")))
  (advice-add 'straight-use-package
              :around (lambda (orig-fn &rest r)
                        (message "     [nix-straight.el] Overriding recipe for '%s'" (car r))
                        (let* ((pkg (car r))
                               (pkg-name (symbol-name pkg))
                               (recipe (if (file-exists-p (straight--repos-dir pkg-name))
                                           (list pkg :local-repo pkg-name :repo pkg-name :type 'git)
                                         (list pkg :type 'built-in))))
                          (message "     --> [nix-straight.el] Recipe generated: %s" recipe)
                          (straight-override-recipe recipe))
                        (apply orig-fn r)))
  (load init-file nil nil t))

;; straight breaks for some reason when
;; it tries to build packages in a nativeComp emacs
(with-eval-after-load "comp"
  (advice-add 'straight--native-compile-file-p
        :before (lambda (&rest r)
                    (if (not (boundp 'comp-deferred-compilation-deny-list))
                        (defvar comp-deferred-compilation-deny-list '())))))

(provide 'setup)
;;; setup.el ends here
