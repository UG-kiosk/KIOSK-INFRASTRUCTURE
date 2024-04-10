#!/bin/bash

terraform_validate() {
    echo "================ TERRAFORM VALIDATE ================="
    echo "                    At directory                    "
    echo "                      $1                            "
    echo "===================================================="
    terraform validate

}

terraform_init() {
    echo "================== TERRAFORM INIT =================="
    echo "                    At directory                    "
    echo "                      $1                            "
    echo "===================================================="
    terraform init
}

terraform_plan() {
    echo "================== TERRAFORM PLAN =================="
    echo "                    At directory                    "
    echo "                      $1                            "
    echo "===================================================="
    terraform plan -out=output.tfplan
}

terraform_apply() {
    echo "================= TERRAFORM APPLY =================="
    echo "                    At directory                    "
    echo "                      $1                            "
    echo "===================================================="
    terraform apply output.tfplan
    echo "Terraform apply completed in $1"
}

process_directory() {
    local dir="$1"
    local dir_name=$(basename "$dir")
    
    cd "$dir" || return
    
    case "$2" in
        validate)
            terraform_validate "$dir_name"
            ;;
        init)
            terraform_init "$dir_name"
            ;;
        plan)
            terraform_plan "$dir_name"
            ;;
        apply)
            terraform_apply "$dir_name"
            ;;
        *)
            echo "Invalid action specified for directory $dir_name"
            ;;
    esac
    
    cd - || return
}

main() {
    local directory="$1"
    local action="$2"
    
    if [ -z "$action" ]; then
        echo "No action specified. Please specify 'validate', 'init', 'plan', or 'apply'."
        exit 1
    fi
    
    if [ -d "$directory" ]; then
        for dir in "$directory"/*/; do
            process_directory "$dir" "$action"
        done
        echo "========================== SUCCESS =========================="
        echo "   All terraform $action operations completed successfully   "
        echo "============================================================="
    else
        echo "Directory $directory does not exist."
    fi
}

if [ $# -lt 2 ]; then
    echo "Usage: $0 <directory> <action>"
    echo "Action should be one of: validate, init, plan, apply"
    exit 1
fi

main "$1" "$2"
